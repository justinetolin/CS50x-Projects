import os

from cs50 import SQL
from flask import Flask, flash, jsonify, redirect, render_template, request, session

# Configure application
app = Flask(__name__)

# Ensure templates are auto-reloaded
app.config["TEMPLATES_AUTO_RELOAD"] = True

# Configure CS50 Library to use SQLite database
db = SQL("sqlite:///birthdays.db")


@app.after_request
def after_request(response):
    """Ensure responses aren't cached"""
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Expires"] = 0
    response.headers["Pragma"] = "no-cache"
    return response


@app.route("/", methods=["GET", "POST"])
def index():
    if request.method == "POST":

        # TODO: Add the user's entry into the database
        name = request.form.get("name")
        month = int(request.form.get("month"))
        day = int(request.form.get("day"))

        # Validate name
        if not name:
            return "Invalid name input. Blank name."

        # Validate month and day
        if month not in range(1,12+1):
            return "Month invalid range! Accepts only be 1 to 12 only."

        days_30 = [4, 6, 9, 11]
        days_31 = [1, 3, 5, 7, 8, 10, 11, 12]

        if month in days_30:
            if day not in range(1,30+1):
                return "Invalid day input for selected month."
        elif month in days_31:
            if day not in range(1,31+1):
                return "Invalid day input for selected month."
        elif month == 2:
            if day not in range(1,29+1):
                return "Invalid day input for selected month."

        db.execute("INSERT INTO birthdays (name, month, day) VALUES(?, ?, ?)", name, month, day)

        return redirect("/")

    else:

        # TODO: Display the entries in the database on index.html
        bdays = db.execute("SELECT * FROM birthdays")

        return render_template("index.html", list=bdays)


