var posQueue = [];
var reQueue = 0;
var Rrunning=0;
var requesting=0;
var Rtimer;

var requestAnimFrame = window.requestAnimationFrame || window.webkitRequestAnimationFrame ||
                       window.mozRequestAnimationFrame || window.msRequestAnimationFrame || 
                       function(c) {window.setTimeout(c, 15)};
/**
   Phoria
   pho·ri·a (fôr-)
   n. The relative directions of the eyes during binocular fixation on a given object
*/					   

function StartStop(){
    if (posQueue==[]){
        new jBox("Modal", {"content":"<span>Run the script before starting the simulation<\/span>","onInit":function() { this.open(); }});
    }
    if (!Rrunning){
        Rnext();
        //top.frames[0].Trun();
    }
    else {
        clearTimeout(Ttimer);
        //top.frames[0].Tstop();
    }
    Rrunning = !Rrunning;
}

function Rnext() {
    RenderCanvas();
    //console.log(posQueue.length);
    if (reQueue < 5 && posQueue.length < 1000) {
	   //console.log("LENGTH");
	   //console.log(posQueue.length);
        requesting=1;
	   reQueue+=1;
        var data = new FormData();
        data.append("_callback", "Tick");
        var xhr = new XMLHttpRequest();
        xhr.open('POST', "/BrazilNut.mipage", true);
        xhr.setRequestHeader("isAPLJax", true);
        xhr.onreadystatechange = function() {                                   
            if (this.readyState == 4 && this.status == 200) {                                       
                APLJaxReturn(eval(this.responseText));
                requesting=0;
                reQueue-=1;				
             }};                               
        xhr.send(data);

    }
    
    Ttimer = setTimeout("Rnext()", 17);
}


function RenderCanvas() {
    if (posQueue.length === 0) {return;}
    // Get canvas DOM
    var canvas = document.getElementById("viewport");
    // Set up scene 
    var scene = new Phoria.Scene();
	var camx = 0.0;
	var spin = 0.0;
    scene.camera.position = {x:camx, y:5.0, z:-15.0};	
    scene.perspective.aspect = canvas.width / canvas.height;
    scene.viewport.width = canvas.width;
    scene.viewport.height = canvas.height;
    // create a canvas renderer
    var renderer = new Phoria.CanvasRenderer(canvas);
    var pos = posQueue.shift() 
    // add a grid to help visualise camera position etc.
    var plane = Phoria.Util.generateTesselatedPlane(8,8,0,20);
    scene.graph.push(Phoria.Entity.create({
      points: plane.points,
      edges: plane.edges,
      polygons: plane.polygons,
      style: {
         drawmode: "wireframe",
         shademode: "plain",
         linewidth: 0.5,
         objectsortmode: "back"
      }
    }));
    scene.graph.push(new Phoria.DistantLight());	
	pos.forEach(function(pos){
		console.log(pos);
		scene.graph.push(Phoria.Entity.create({
		//points: [{x:0.0,y:0.0,z:0.0}],
		points:[{x:pos[0],y:pos[1],z:pos[2]}],
			style:{
				color: [10,200,150],
				drawmode: "point",
				shademode: "lightsource",
				linewidth: 10,
				linescale: 1
			}
		}));
	})
    // scene.graph.push(Phoria.Entity.create({
		// points: [{x:0.0,y:0.0,z:0.0}],		
		// style:{
			// color:[0,100,100],
			// drawmode: "point",
			// shademode: "lightsource",
			// linewidth: 5,
			// linescale: 2
		// }
          		
	// }));
    var fnAnimate = function() {
		camx=10*Math.sin(spin+=0.01);
		scene.camera.position = {x:camx, y:5.0, z:-15.0};
		scene.modelView();
		renderer.render(scene);
		requestAnimFrame(fnAnimate);
}
requestAnimFrame(fnAnimate);
    //var ctx = c.getContext("2d");
    //canvas.width = 300
    //canvas.height = 300
    // var grd = canvas.createRadialGradient(75, 50, 5, 90, 60, 100);
    // grd.addColorStop(0, "red");
    // grd.addColorStop(1, "white");

    // canvas.clearRect(0, 0, c.width, c.height);
    // pos.forEach(function(pos){
        // canvas.beginPath();
        // canvas.arc(pos[0]*c.width,pos[1]*c.height,1,0,2*Math.PI);
        // canvas.closePath()
        
        // canvas.fillStyle='white';
        // ctx.fillStyle = grd;
        // ctx.fill();})
}