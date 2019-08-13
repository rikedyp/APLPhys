var posQueue = [];
var pos;
var reQueue = 0;
var Rrunning=0;
var requesting=0;
var Rtimer;
//var atoms = [];
//var scene;

var requestAnimFrame = window.requestAnimationFrame || window.webkitRequestAnimationFrame ||
                       window.mozRequestAnimationFrame || window.msRequestAnimationFrame || 
                       function(c) {window.setTimeout(c, 15)};

/**
   Phoria
   pho·ri·a (fôr-)
   n. The relative directions of the eyes during binocular fixation on a given object
*/					   

var camx = 0.0;
var spin = 0.0;
var scale = 6.0;

// Get canvas DOM
var canvas = document.getElementById("viewport");

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
    console.log(posQueue.length);
    if (reQueue < 5 && posQueue.length < 1000) {
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

//function createAtom(){
	//console.log("createAtom");
	
	
    //for (i=0;i<pos[0].length;i++){
		
	//}	
	
	
	//for (i=0;i<pos.length;i++){
//	atoms.push(atom);
//	scene.graph.push(atom);
	//}
	//		pos[i] = pos[i].map((a, j) => a * scale);
			
		//	atom.translate(pos[i]);				
//}

//var atomstyle = Phoria.Entity.createStyle()
//style = 

function RenderCanvas() {

    if (posQueue.length === 0) {return;}
    
    // Set up scene 
    var scene = new Phoria.Scene();
	//createAtoms();
    scene.camera.position = {x:camx, y:5.0, z:-55.0};	
    scene.perspective.aspect = canvas.width / canvas.height;
    scene.viewport.width = canvas.width;
    scene.viewport.height = canvas.height;
    // create a canvas renderer
    var renderer = new Phoria.CanvasRenderer(canvas);
    pos = posQueue.shift() 
    // add a grid to help visualise camera position etc.
    var plane = Phoria.Util.generateTesselatedPlane(20,20,-10,20);
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

    
	//pos.forEach(pushAtom(pos, b, scene));
	// Loop over particles
	//console.log("Render");
	//var s = Phoria.Util.generateSphere(0.1,5,5);
	// for (atom of atoms){
		// console.log(atom);
		// atom.translate()
	// }
	var s = Phoria.Util.generateSphere(0.1,5,5);
	// var atomstyle = Phoria.Entity.createStyle({
		// points: s.points,
		// edges: s.edges,
		// polygons: s.polygons,
		// style:{
			// drawmode: "solid",
			// diffuse: 1,
			// specular: 16,
			// shademode: "lightsource"
		// }
	// });
	for (i=0;i<pos.length;i++){
		var atom = Phoria.Entity.create({
			points: s.points,
			edges: s.edges,
			polygons: s.polygons,
			style:{
				drawmode: "solid",
				diffuse: 1,
				specular: 16,
				shademode: "lightsource"
			}});
		//atom.style = atomstyle;
		scene.graph.push(atom);
		pos[i] = pos[i].map((a, j) => a * scale);
		// console.log(atoms[i]);
		//console.log(atoms.length);
		// atoms[i].translate(pos[i]);
		//
		//atom.translate(pos[i]);
		// 3D Spheres for pretty particles
		
		//var axes = Object.keys(s.points[0]);
		// Loop over sphere defining points
		//for (j=0;j<s.points.length;j++) {
		// var atom = Phoria.Entity.create({
			// points: s.points,
			// edges: s.edges,
			// polygons: s.polygons,
			// style:{
				// diffuse: 1,
				// specular: 16,
				// shademode: "lightsource"
				// }
		// });
		//console.log(scene.graph[i]);
		
		
		atom.translate(pos[i]);				
		//}
	}
	//pushAtom(pos[0],b,scene);
	
    var fnAnimate = function() {
		camx=10*Math.sin(spin+=0.01);
		scene.camera.position = {x:camx, y:5.0, z:-15.0};
		scene.modelView();
		renderer.render(scene);
		//requestAnimFrame(fnAnimate);
	}
	
	
	
			// s.points.forEach(point){
			// for (var axis of axes){
				// points[axis]+=pos[axis];
			// }
		// }
	    
	
	
	requestAnimFrame(fnAnimate);
};

