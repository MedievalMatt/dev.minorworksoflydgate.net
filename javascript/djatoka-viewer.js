

function lightbox(id) {
    var id_number = id;
    
    //	document.getElementById(id_number).style.display='block';
    //    document.getElementById('fade').style.display='block';
    
    //    window.scrollTo(0,0);
    
    document.getElementById(id_number).style.display = 'block';
    document.getElementById('fade').style.display = 'block';
}

function lightbox_close(id) {
    var id_number = id;
    
    var elems = document.getElementsByClassName('light');
    for (var i = 0; i < elems.length; i++) {
        elems[i].style.display = 'none';
    }
    document.getElementById('fade').style.display = 'none';
}

function edit_toggle_visibility() {
    var e = document.getElementById('EditBlock');
    var f = document.getElementById('EditLink');
    var g = document.getElementById('EditWrapper');
    
    if (e.style.display == 'block') {
        e.style.display = 'none';
        f.style.display = 'inline';
    } else {
        e.style.display = 'block';
        f.style.display = 'none';
    }
}

function supplied_toggle_visibility(){
    var supplied = document.getElementById("supplied");
 //   suppliedContent = supplied.innerHTML;
    supplied.innerHTML = "TEST TEST TEST"; 
   
}

function init() {
    var file_number = window.location.search.substring(8);
    
    
    
    var metadataUrl = "http://localhost:8080/adore-djatoka/resolver?url_ver=Z39.88-2004&rft_id=http://localhost:8888/Images/clopton_chapel-" + file_number + ".jp2&svc_id=info:lanl-repo/svc/getMetadata";
    
    
    
    /*		var OUlayer = new OpenLayers.Layer.OpenURL( "OpenURL",
    "http://localhost:8080/", {layername: 'basic', format:'image/jpeg', rft_id:'http://www.matthewedavis.net/Images/Clopton_chapel-0480.jp2', metadataUrl: metadataUrl} ); */
    
    var OUlayer = new OpenLayers.Layer.OpenURL("OpenURL",
    "http://localhost:8080/", {
        layername: 'basic', format: 'image/jpeg', rft_id: 'http://localhost:8888/Images/clopton_chapel-' + file_number + '.jp2', metadataUrl: metadataUrl
    });
    
    var metadata = OUlayer.getImageMetadata();
    var resolutions = OUlayer.getResolutions();
    var maxExtent = new OpenLayers.Bounds(0, 0, metadata.width, metadata.height);
    var tileSize = OUlayer.getTileSize();
    var options = {
        resolutions: resolutions, maxExtent: maxExtent, tileSize: tileSize
    };
    var map = new OpenLayers.Map('map', options);
    map.addLayer(OUlayer);
    var lon = metadata.width / 2;
    var lat = metadata.height / 2;
    map.setCenter(new OpenLayers.LonLat(lon, lat), 0);
}
// JavaScript Document