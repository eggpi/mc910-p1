function showNews (newsName) {
    document.getElementById("back").style.display="block";
    document.getElementById(newsName).style.display="block";
};

function hideNews () {
    document.getElementById("back").style.display="none";
    var texts = document.getElementsByClassName("text");
    for(i = 0; i < texts.length; i++) {
        texts[i].style.display="none";
    }
};
