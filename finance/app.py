import os

from cs50 import SQL
from flask import Flask, flash, redirect, render_template, request, session
from flask_session import Session
from werkzeug.security import check_password_hash, generate_password_hash
from datetime import datetime

from helpers import apology, login_required, lookup, usd

# Configure application
app = Flask(__name__)

# Custom filter
app.jinja_env.filters["usd"] = usd

# Configure session to use filesystem (instead of signed cookies)
app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)

# Configure CS50 Library to use SQLite database
db = SQL("sqlite:///finance.db")


@app.after_request
def after_request(response):
    """Ensure responses aren't cached"""
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Expires"] = 0
    response.headers["Pragma"] = "no-cache"
    return response


@app.route("/")
@login_required
def index():
    """Show portfolio of stocks"""
    base = db.execute(
        "SELECT symbol, SUM(share) as shares FROM transactions WHERE user_id = ? GROUP BY symbol", session["user_id"])

    # Add the price from lookup function
    total = 0
    for entry in base:
        stock = lookup(entry["symbol"])
        entry["price"] = stock["price"]
        entry["total"] = round(stock["price"] * entry["shares"], 2)
        total = total + entry["total"]

    cash = db.execute("SELECT cash FROM users WHERE id = ?",
                      session["user_id"])

    return render_template("index.html", portfolio=base, total=total, cash=cash[0]["cash"])


@app.route("/buy", methods=["GET", "POST"])
@login_required
def buy():
    """Buy shares of stock"""
    if request.method == "POST":
        stock = lookup(request.form.get("symbol"))
        share = request.form.get("shares")
        # Validate shares
        try:
            share = int(share)
            if share <= 0:
                return apology("shares must be a positive whole number")

        except (ValueError, TypeError):
            return apology("shares must be a positive whole number")

        if not stock:
            return apology("invalid symbol")
        elif share < 1:
            return apology("invalid share")

        # Check affordability
        user = db.execute("SELECT * FROM users WHERE id = ?",
                          session["user_id"])
        stock_worth = share * stock["price"]
        if user[0]["cash"] < stock_worth:
            return apology("can't afford")
        else:
            # Deduct the stock worth
            balance = user[0]["cash"] - stock_worth
            db.execute("UPDATE users SET cash = ? WHERE id = ?",
                       balance, session["user_id"])

            # Update transactions
            db.execute("INSERT INTO transactions (user_id, symbol, share, price) VALUES(?, ?, ?, ?)",
                       session["user_id"], stock["symbol"], share, stock["price"])
            return redirect("/")
    else:
        return render_template("buy.html")


@app.route("/history")
@login_required
def history():
    """Show history of transactions"""
    history = db.execute(
        "SELECT symbol, share, price, datetime FROM transactions WHERE user_id = ?", session["user_id"])
    return render_template("history.html", history=history)


@app.route("/login", methods=["GET", "POST"])
def login():
    """Log user in"""

    # Forget any user_id
    session.clear()

    # User reached route via POST (as by submitting a form via POST)
    if request.method == "POST":
        # Ensure username was submitted
        if not request.form.get("username"):
            return apology("must provide username", 403)

        # Ensure password was submitted
        elif not request.form.get("password"):
            return apology("must provide password", 403)

        # Query database for username
        rows = db.execute(
            "SELECT * FROM users WHERE username = ?", request.form.get(
                "username")
        )

        # Ensure username exists and password is correct
        if len(rows) != 1 or not check_password_hash(
            rows[0]["hash"], request.form.get("password")
        ):
            return apology("invalid username and/or password", 403)

        # Remember which user has logged in
        session["user_id"] = rows[0]["id"]

        # Redirect user to home page
        return redirect("/")

    # User reached route via GET (as by clicking a link or via redirect)
    else:
        return render_template("login.html")


@app.route("/logout")
def logout():
    """Log user out"""

    # Forget any user_id
    session.clear()

    # Redirect user to login form
    return redirect("/")


@app.route("/quote", methods=["GET", "POST"])
@login_required
def quote():
    """Get stock quote."""
    if request.method == "POST":
        result = lookup(request.form.get("symbol"))

        # Validate lookup
        if not result:
            return apology("invalid symbol")

        return render_template("quote.html", quote=result)
    else:
        return render_template("quote.html")


@app.route("/register", methods=["GET", "POST"])
def register():
    """Register user"""
    if request.method == "POST":
        username = request.form.get("username")
        password = request.form.get("password")
        repass = request.form.get("confirmation")

        # Validate username
        if not username:
            return apology("must provide username")

        # Ensure password was submitted
        elif not password:
            return apology("must provide password")

        elif not repass:
            return apology("re-type password")

        # Check password re-attempt
        if password != repass:
            return apology("passwords does not match")

        rows = db.execute(
            "SELECT * FROM users WHERE username LIKE ?", "%" + username + "%")

        if len(rows) != 0:
            return apology("username already exists")

        hash = generate_password_hash(password)

        db.execute(
            "INSERT INTO users (username, hash) VALUES(?, ?)", username, hash)

        # Save session id
        rows = db.execute("SELECT * FROM users WHERE username = ?", username)
        session["user_id"] = rows[0]["id"]

        return redirect("/")

    else:
        return render_template("register.html")


@app.route("/sell", methods=["GET", "POST"])
@login_required
def sell():
    """Sell shares of stock"""
    if request.method == "POST":
        if request.method == "POST":
            stock = lookup(request.form.get("symbol"))
            share = request.form.get("shares")

            # Validate shares
            try:
                share = int(share)
                if share <= 0:
                    return apology("shares must be a positive whole number")

            except (ValueError, TypeError):
                return apology("shares must be a positive whole number")

            if not stock:
                return apology("invalid symbol")

            existing_shares = db.execute(
                "SELECT SUM(share) as shares FROM transactions WHERE user_id = ? AND symbol = ?", session["user_id"], stock["symbol"])
            if share > existing_shares[0]["shares"]:
                return apology("invalid share range")

            # Calc stock worth
            user = db.execute(
                "SELECT * FROM users WHERE id = ?", session["user_id"])

            stock_worth = share * stock["price"]

            # Deduct the stock worth
            balance = user[0]["cash"] + stock_worth
            db.execute("UPDATE users SET cash = ? WHERE id = ?",
                       balance, session["user_id"])

            # Update transactions
            db.execute("INSERT INTO transactions (user_id, symbol, share, price) VALUES(?, ?, ?, ?)",
                       session["user_id"], stock["symbol"], f"-{share}", stock["price"])
            return redirect("/")
    else:
        symbols = db.execute(
            "SELECT DISTINCT(symbol) FROM transactions WHERE user_id = ?", session["user_id"])
        return render_template("sell.html", list=symbols)
