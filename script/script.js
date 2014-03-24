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

function r(f){/in/(document.readyState)?setTimeout(r,9,f):f()}
r(function(){
    var months = ["janeiro", "fevereiro", "março", "abril", "maio", "junho",
        "julho", "agosto", "setembro", "outubro", "novembro", "dezembro"];
    var today = new Date();
    document.getElementById("date").innerHTML = today.getDate() +
        " de " + months[today.getMonth()] + " de " + today.getFullYear();
});
