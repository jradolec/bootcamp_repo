var queryURL='https://api.nytimes.com/svc/search/v2/articlesearch.json?q=election'+ +'&api-key=5eSlBSNpUUoEi9pwAYZa0pPiDZOsWopX';

$.ajax({
    url: queryURL,
    method: "GET"
}).then(function(response) {


}








//

function build() {
    var qurl = "https://api.nytimes.com/svc/search/v2/articlesearch.json?";
  
    // Begin building an object 
    // Set the API key
    var qkey = { "api-key": "NEED_KEY_HERE" };
  
    // Grab text the user typed into the search input, add to the queryParams object
    qkey = $("#search-term")
      .val()
      //eliiminate garbage at the end ____
      .trim();
  
   
    var startYear = $("#start-year")
      .val()
      .trim();
  
    if (parseInt(beginyear)) {






// .on("click") function associated with the Search Button
$("#run-search").on("click", function(event) {
   
    event.preventdefault();
  
    
    clear();
  
    // Build the query URL for the ajax request to the NYT API
    var qurl = querybuild();
  
    //build query then add to update page
    $.ajax({
      url: qurl,
      method: "GET"
    }).then(pagepush);
  });
  
  //  .on("click") function associated with the clear button
  $("#clear-all").on("click", clear);
  