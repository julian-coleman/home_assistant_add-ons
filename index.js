var str = ""

function reqListener() {
  statuses = this.responseText;
  const status = statuses.split("\n");
  // .ovpn file
  if (status[0].endsWith("YES")) {
    document.getElementById("ovpn-status").innerHTML = "Uploaded";
    document.getElementById("ovpn-download").style.display = "block";
  } else {
    document.getElementById("ovpn-status").innerHTML = "Missing";
    document.getElementById("ovpn-download").style.display = "none";
  }
  // .text file
  if (status[1].endsWith("YES")) {
    document.getElementById("text-status").innerHTML = "Uploaded";
    document.getElementById("text-download").style.display = "block";
  } else {
    document.getElementById("text-status").innerHTML = "Missing";
    document.getElementById("text-download").style.display = "none";
  }
}

var req = new XMLHttpRequest();
req.open("GET", "./cgi-bin/status.sh");
req.send();
req.addEventListener("load", reqListener);
