var Controller = function (element, side) {
    this.name = "controller";
    this.domElement = document.createElement('div');
    this.side = side;

    this.optionsArea = document.createElement('div');
    this.domElement.append(this.optionsArea);

    element.append(this.domElement);

    //create "end" button
    this.sendButton = document.createElement('div');
    this.sendButton.className = "option end " + this.side;

    //inner text element
    var inner = document.createElement('div');
    inner.innerHTML = "Send";
    this.sendButton.append(inner);

    inner.addEventListener('click', function () {
        this.endMessage();
    }.bind(this));

    this.domElement.append(this.sendButton);

    //start off inactive
    this.active = false;
}

Controller.prototype = {
    populate : function (wordArray) {

        this.clearOptions();

        var obj = this;
        wordArray.forEach(function (word) {
            this.spawnWordOption(word);
        }.bind(this)); //don't forget to bind to keep 'this' === self;

    },

    populateMarkov : function (seedWord) {

        this.clearOptions();

        wordArray = [];

        //If the seedword exists in the markov database, add words
        //to the current choices based on it
        if(markov[seedWord] != undefined){
            var wordMapping = Object.assign({}, markov[seedWord]);

            probabilityTotal= Object.keys(wordMapping).reduce(
                function (sum, key) {
                    return sum + wordMapping[key];
                }, 0 //initial value
            );

            for (var j = 0; j < Math.min(Object.keys(wordMapping).length, 6); j++) {
                var i, sum=0, r=Math.random() * probabilityTotal;
                probabilityLoop:
                    for (i in wordMapping) {
                        sum += wordMapping[i];
                        if (r <= sum){
                            wordArray.push(i);
                            probabilityTotal -= wordMapping[i];
                            wordMapping[i] = 0;
                            break probabilityLoop;
                        };
                    }
            }
        }

        console.log(wordArray);

        //add some random words if the list is not long enough
        // for (var i = wordArray.length; i < 8; i++) {
        //     wordArray.push(getRandomWord());
        // }

        var obj = this;
        wordArray.forEach(function (word) {
            this.spawnWordOption(word);
        }.bind(this)); //don't forget to bind to keep 'this' === self;

    },

    clearOptions : function () {
        while (this.optionsArea.firstChild) {
            this.optionsArea.removeChild(this.optionsArea.firstChild);
        }
    },

    spawnWordOption : function (word) {
        var e = document.createElement('div');
        e.className = "option " + this.side;

        //inner word element
        var inner = document.createElement('div');
        inner.innerHTML = word;
        e.append(inner);

        inner.addEventListener('click', function () {
            if (this.message === undefined){
                this.message = new Message(this.side, word);
            }else{
                this.message.addWord(word);
            }

            //refresh the markov chain based on this word
            this.populateMarkov(word);

            var percent = (this.message.messageText.length/140) * 100;

            color = this.side == 'left' ? "#2165db" : "#f3903d";

            this.sendButton.childNodes[0].setAttribute( 'style',
                "background: linear-gradient(to right, "
                + color + ", "
                + color
                + " "
                + percent +
                "% , #ccc "
                + percent +
                "% , #ccc);"
            );

            //check if we've exceeded the limit
            if (percent > 100){
                this.endMessage();
            }
        }.bind(this));

        this.optionsArea.append(e);
    },
    endMessage : function () {
        if (!this.active){ return; }

        this.sendButton.childNodes[0].setAttribute( 'style', "background: #ccc");
        //end the message (and switch control somehow)
        //add a period maybe?
        this.message.end();
        this.message = undefined;

        this.clearOptions();
        this.active = false;
        //Flip global side

        flipSides();
    }
}
