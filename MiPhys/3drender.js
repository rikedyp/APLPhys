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
var scale = 12.0;

// Get canvas DOM
var canvas = document.getElementById("viewport");
var baby;

function StartStop(){
    if (!Rrunning){
        Rnext();
    }
    else {
        clearTimeout(Ttimer);
    }
    Rrunning = !Rrunning;
}

function getAPLPhys(){
	console.log(posQueue.length);
	return new Promise(function (resolve) {
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
					resolve();
					reQueue-=1;				
				 }
			};                               
			xhr.send(data);
		}
	});
}

function Rnext() {
    //RenderCanvas();
	RenderBabylon();    
    getAPLPhys();
    Ttimer = setTimeout("Rnext()", 17);
}

function stepScene() {
	pos = posQueue.shift();
	//console.log(pos);
	for (i=0;i<pos.length;i++){
		var atom = scene.getMeshByID("atom"+i);
		//console.log(atom);
		atom.position.x = pos[i][0]*scale;
		atom.position.y = pos[i][1]*scale;
		atom.position.z = pos[i][2]*scale;
	}
}

var createScene = function(engine) {
	// BJS Scene 
	//scene.dispose();
	var scene = new BABYLON.Scene(engine);
	// Scene optimisations https://doc.babylonjs.com/how_to/optimizing_your_scene
	scene.autoClear = false; // Color buffer
	scene.autoClearDepthAndStencil = false; // Depth and stencil, obviously
	scene.blockMaterialDirtyMechanism = true; 
	scene.useMaterialMeshMap = true;
	AM = new BABYLON.ActionManager(scene);
	//var camera = new BABYLON.FreeCamera('camera1', new BABYLON.Vector3(0, 5,-10), scene);
	var camera = new BABYLON.ArcRotateCamera("camera", 0, 0, 10, new BABYLON.Vector3(0,0,0), scene);
	//camera.attachControl(canvas, true);
	// target the camera to scene origin
	camera.setTarget(new BABYLON.Vector3(0,10,10));
	// attach the camera to the canvas
	camera.attachControl(canvas, true);
	// create a basic light, aiming 0,1,0 - meaning, to the sky
	var light = new BABYLON.HemisphericLight('light1', new BABYLON.Vector3(0,1,0), scene);
	// create a built-in "ground" shape;
	var ground = BABYLON.Mesh.CreateGround('ground1', 10, 10, 10, scene);
	ground.position = new BABYLON.Vector3(5,0,5);
	var groundmesh = new BABYLON.StandardMaterial("groundmesh", scene);
	groundmesh.wireframe = true;
	ground.material = groundmesh;

	//for (var i=0;i<pos.length;i++){
	//	var sphere = BABYLON.Mesh.CreateSphere('atom', 2, 0.5, scene);
	//}
	pos = posQueue.shift();
	//var particles = new BABYLON.ParticleSystem("particles", pos.length, scene);
	// Create atoms in scene
	var sphere = BABYLON.Mesh.CreateSphere('atom', 1, 0.3, scene);
	var spheremat = new BABYLON.StandardMaterial("spheremat", scene);
	//spheremat.wireframe = true;
	spheremat.alpha = 0.5;
	sphere.material = spheremat;
	sphere.doNotSyncBoundingInfo = true;
	sphere.cullingStrategy = BABYLON.AbstractMesh.CULLINGSTRATEGY_BOUNDINGSPHERE_ONLY;
	sphere.isVisible = false;
	for (i=0;i<pos.length;i++){
		var atom = sphere.createInstance("atom"+i);	
	}
	
	return scene;
}

async function WakeBaby() {
	// Dispose of old scene
	//scene.dispose();
	// Get first set of frames to render
	posQueue = [];
	await getAPLPhys();
	console.log("Baby awake");	
	// Create engine and scene, dispose of old ones if applicable
	try {
		scene.dispose();
		engine.dispose();
	}
	catch (error) {
		baby = new BABYLON.Engine(canvas, true);
		scene = createScene(baby);
	}
	//scene = createScene(baby);
	//scene.clearColor = BABYLON.Color3.Blue();
	// TODO: What is (,true)?
	//return baby;
}

function RenderBabylon() {
	if (posQueue.length === 0) {return;}
	//console.log(scene);
	stepScene();
	// Create Babylon scene 
	//var scene = createScene(baby);
	baby.runRenderLoop(function(){
		scene.render();
	});
}

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

	var s = Phoria.Util.generateSphere(0.1,5,5);

	for (var i=0;i<pos.length;i++){
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

