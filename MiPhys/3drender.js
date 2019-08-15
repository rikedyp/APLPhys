var posQueue = [];
var pos;
var reQueue = 0;
var Rrunning=0;	   
var spin = 30.0;
var scale = 12.0;
var SPS;

// Get canvas DOM
var canvas = document.getElementById("viewport");
var baby;

// Function attached to "Run script" button
async function WakeBaby() {
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
}

// Function attached to "Start/Stop" button 
function StartStop(){
    if (!Rrunning){
        Rnext();
    }
    else {
        clearTimeout(Ttimer);
    }
    Rrunning = !Rrunning;
}

// Perform callback to the server to get particle trajectories
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
					resolve();
					reQueue-=1;				
				 }
			};                               
			xhr.send(data);
		}
	});
}

function Rnext() {
	// Render the next frame
	RenderBabylon();    
    getAPLPhys();
    Ttimer = setTimeout("Rnext()", 17); // Every 17ms
}

function stepScene() {
	// Get latest positions
	pos = posQueue.shift();
	// Update particle positions
	SPS.updateParticle = updateParticle;
	SPS.setParticles();
}

var updateParticle = function(particle){
	pid = particle.idx
	particle.position.x = pos[pid][0]*scale;
	particle.position.y = pos[pid][1]*scale;
	particle.position.z = pos[pid][2]*scale;
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
    // Set up camera
	var camera = new BABYLON.ArcRotateCamera("Camera", 30, 1, 20, new BABYLON.Vector3(7, 5, 4), scene);
	camera.attachControl(canvas, true);
	// Create a basic light, aiming 0,1,0 - meaning, to the sky
	var light = new BABYLON.HemisphericLight('light1', new BABYLON.Vector3(0,1,0), scene);
	// Create a built-in "ground" shape;
	var ground = BABYLON.Mesh.CreateGround('ground1', 10, 10, 10, scene);
	ground.position = new BABYLON.Vector3(5,0,5);
	var groundmesh = new BABYLON.StandardMaterial("groundmesh", scene);
	groundmesh.wireframe = true;
	ground.material = groundmesh;
	// Get this frame's atom positions
	pos = posQueue[0];
	// Set up SPS
	SPS = new BABYLON.SolidParticleSystem("SPS", scene);
	var sphere = BABYLON.MeshBuilder.CreateSphere("s", {diameter:0.3, segments: 1}, scene);
	SPS.addShape(sphere, pos.length);      // 20 spheres
	sphere.dispose();
	var mesh = SPS.buildMesh();  // Build and display the mesh
	
	return scene;
}

function RenderBabylon() {
	if (posQueue.length === 0) {return;}
	stepScene();
	baby.runRenderLoop(function(){
		scene.render();
	});
}
