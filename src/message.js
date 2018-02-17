var Message = function(side, initialMessage){
    this.domElement = document.createElement('div');
    this.textArea = document.createElement('div');
    //this.textArea.innerHTML = initialMessage;

    this.addWord(initialMessage);

    this.domElement.append(this.textArea);
    this.domElement.className = 'entry';

    if (side === 'left'){
        this.domElement.className += " left-just";
    }else if (side === 'right'){
        this.domElement.className += " right-just";
    }else{
        console.warn("specify 'left' or 'right' for the message");
    }

    document.getElementById('messagePane').append(this.domElement);

    this.domElement.scrollIntoView(true);
}

Message.prototype = {
    addWord : function (word) {

        wordSpan = document.createElement('span');
        wordSpan.innerHTML = " " + word;
        setTimeout(function () {
            wordSpan.className = "show";
        }, 100);
        this.textArea.append(wordSpan);

        this.messageText += " " + word;

        this.domElement.scrollIntoView(true);
        //add the word to the message's string
    },
    end : function () {
        this.domElement.className += " sent";

        this.domElement.scrollIntoView(true);
        //add the word to the message's string
    },
}
