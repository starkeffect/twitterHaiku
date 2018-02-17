keys = [];

fetch("markov.json")
  .then(response => response.json())
  .then(json => {markov = json; keys = Object.keys(markov); flipSides();});

function getRandomWord() {
    n = Math.floor(Math.random() * keys.length);
    return keys[n];
}

//currentside 0=left 1=right
var currentSide = 0;

var leftController = new Controller(document.getElementById('leftController'),'left');

var rightController = new Controller(document.getElementById('rightController'),'right');

controllers = [leftController, rightController];

function flipSides(){
    //Switch which side is in control
    currentSide = 1-currentSide;
    controllers[currentSide].active = true;

    controllers[currentSide].populate([
        getRandomWord(),
        getRandomWord(),
        getRandomWord(),
        getRandomWord(),
        getRandomWord(),
        getRandomWord(),
        getRandomWord(),
        getRandomWord(),
    ]);

}
