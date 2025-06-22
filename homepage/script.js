// Change bg color on scroll
$(function () {
    'use strict';
    $(window).scroll(function () {
        var windowTop = $(window).scrollTop();
        var windowHeight = $(window).height();

        $('.part').each(function () {
            var elementTop = $(this).offset().top;
            var elementHeight = $(this).outerHeight();
            var bgColor = $(this).data('background');

            if (
                elementTop <= windowTop + (windowHeight * 2 / 3) &&
                elementTop + elementHeight > windowTop + (windowHeight * 2 / 3)
            ) {
                $('body').css('background-color', bgColor);
            }
        });
    });
});


const sections = document.querySelectorAll(".hidden");
const observer = new IntersectionObserver(
    entries => {
        entries.forEach(entry => {
            entry.target.classList.toggle("show", entry.isIntersecting);
            // if (entry.isIntersecting) observer.unobserve(entry.target)
        });
    },
    {
        threshold: 0.75
    }
);


sections.forEach(section => {
    observer.observe(section);
});

// Version 2

const sections2 = document.querySelectorAll(".hidden2");
const observer2 = new IntersectionObserver(
    entries => {
        entries.forEach(entry => {
            entry.target.classList.toggle("show", entry.isIntersecting);
            if (entry.isIntersecting) observer2.unobserve(entry.target);
            DetectFootTwo();
        });
    },
    {
        threshold: 0.75
    }
);

sections2.forEach(section => {
    observer2.observe(section);
});


// ! Hacker type effect para bongga
const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
let interval = null;

const targetElement = document.querySelector(".type-effect");
function startTypingEffect() {
    let iteration = 0;

    clearInterval(interval);

    interval = setInterval(() => {
        targetElement.innerText = targetElement.innerText
            .split("")
            .map((letter, index) => {
                if (index < iteration) {
                    return targetElement.dataset.value[index];
                }

                return letters[Math.floor(Math.random() * 26)];
            })
            .join("");

        if (iteration >= targetElement.dataset.value.length) {
            clearInterval(interval);
        }

        iteration += 1 / 4;
    }, 30);
}

setTimeout(() => {
    targetElement.style.opacity = 1;
    targetElement.style.animationName = 'fadeIn';
    startTypingEffect();
}, 3000);



// ! Sequence Animation
function triggerAnimationSequence(element) {
    const lettersArray = element.textContent.trim().split("");
    let delay = 0;

    element.innerHTML = "";
    lettersArray.forEach((letter) => {
        let span = document.createElement("SPAN");
        let attr = document.createAttribute("data-animate");

        span.setAttributeNode(attr);
        span.innerHTML = letter;
        span.style.transitionDelay = `${delay}ms`;
        element.appendChild(span);

        void span.offsetWidth;
        span.classList.add("animated");
        delay += 80;
    });

    element.removeAttribute("data-animate");
};
// ! Intersection Observer for triggerAnimationSequence
const headingAnimElements = document.querySelectorAll(".heading-anim");
const animObserver = new IntersectionObserver(entries => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            triggerAnimationSequence(entry.target);
            animObserver.unobserve(entry.target);
        }
    });
});

headingAnimElements.forEach(element => {
    animObserver.observe(element);
});




// ! Detect foot-two's classlist
function DetectFootTwo() {
    const footElement = document.getElementById('foot2');
    const passionElements = document.querySelectorAll('.loveit');
    const floaterElement = document.getElementById('floater');

    if (footElement.classList.contains('show')) {
        let delay = 500;

        passionElements.forEach(element => {
            setTimeout(() => {
                element.classList.add('show');
            }, delay);
            delay += 1000;
        });

        setTimeout(() => {
            floaterElement.style.color = 'red';
            floaterElement.textContent = "Please, basahin mo toh kahit mahaba";
            // floaterElement.classList.add('hidden');
        }, delay);

    } else {
        console.log("No Show Class on Foot2 Element.");
    }
}

