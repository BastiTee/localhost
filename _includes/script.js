function toggleTableOfContent() {
    var x = document.getElementById("table-of-content");
    // console.log("Toggle toc from " + x.style.display)
    if (x.style.display === "none") {
      x.style.display = "block";
    } else {
      x.style.display = "none";
    }
  }