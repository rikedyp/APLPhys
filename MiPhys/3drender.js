//https://playground.babylonjs.com/#LXXL6Y#1

var posQueue = [];
var groups = [];
var pos;
var reQueue = 0;
var Rrunning=0;	   
var spin = 30.0;
var scale = 12.0;
var SPS;
var step;
var dumpfreq;
var re_time = 0;
var frame_time = 17;

// TODO deprecate RenderCanvas 
// TODO tabs to 2 spaces 
// TODO make style consistent

// Get canvas DOM
var canvas = document.getElementById("viewport");
var baby;

// Function attached to "Run script" button
async function WakeBaby() {
	// Reset step counter
	step = 0;
	document.getElementById("step").innerHTML = "Step: " + step;
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
		baby.runRenderLoop(function(){
			scene.render();
		});
	}
}

function BabyMenu(){
	// Clear old form 
	const babySet = document.getElementById("babySet");
	while (babySet.firstChild) {
		babySet.removeChild(babySet.firstChild);
	}
	// Create new form 
	var form = document.createElement("form");
	var groupSelect = document.createElement("select");
	groupSelect.name = "groupSelect";
	groupSelect.id = "groupSelect";
	for (var i=0; i<groups.length; i++) {
		//console.log(groups[i]);
		var option = document.createElement("option");
		//console.log(option.value);
		if (i===0) {
			option.value = [0,groups[i]];
		} else {
			option.value = [groups[i-1], groups[i-1] + groups[i]];
		}
		//option.value = [groups[i-1],groups[i-1]+groups[i]];
		option.innerHTML = (i+1) + " (" + groups[i] + ")";
		groupSelect.appendChild(option);
	}
	var p = document.createElement("p");
	p.innerHTML = "Atom group (number of atoms)";
	var div = document.createElement("div");
	div.appendChild(groupSelect);
	div.appendChild(p);
	form.appendChild(div);
	var colSelect = document.createElement("input");
	colSelect.type = "color";
	colSelect.name = "colSelect";
	colSelect.id = "colSelect";
	div = document.createElement("div");
	p = document.createElement("p");
	p.innerHTML = "Atom colour";
	div.appendChild(colSelect);
	div.appendChild(p);	
	form.appendChild(div);
	var applyBtn = document.createElement("button");
	applyBtn.innerHTML = "Apply";
	applyBtn.type = "button";
	applyBtn.addEventListener("click", updateScene);
	form.appendChild(applyBtn);
	
	babySet.appendChild(document.createElement("br"));
	babySet.appendChild(form);
}

function updateScene() {
	//console.log("update sceneeee");
	// Update mesh and particle properties from the Render Settings
	SPS.updateParticle = newParticleColors;
	SPS.setParticles();
}

var newParticleColors = function(particle) {
	var pid = particle.idx
	var color = document.getElementById("colSelect").value;
	var group = document.getElementById("groupSelect").value.split(",");
	if (group[0] <= pid && pid < group[1]) {
		//console.log(group);
		//console.log(pid);
		particle.color = BABYLON.Color3.FromHexString(color);
		//console.log(color);		
	}	
	// particle.color.r = 0.5;
	// particle.color.g = 0.5;
	// particle.color.b = 0.1;
	// particle.color.a = 0.8;
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
		//console.log(reQueue)
		// TODO standardise FunNames + var_names
		if (reQueue < 6 && posQueue.length < 600) {
		//if (re_time < 1000) {			
			reQueue+=1;
			var re_start_time = new Date().getTime();
			var data = new FormData();
			data.append("re_time", re_time);
			data.append("_callback", "Tick");
			var xhr = new XMLHttpRequest();
			xhr.open('POST', "/BrazilNut.mipage", true);
			xhr.setRequestHeader("isAPLJax", true);
			xhr.onreadystatechange = function() {                                   
				if (this.readyState == 4 && this.status == 200) { 
					re_time = new Date().getTime() - re_start_time;
					//console.log(re_time);
					APLJaxReturn(eval(this.responseText));
					resolve();
					reQueue-=1;				
				 }
			};                               
			xhr.send(data);
		}
	});
}

function StepOnce(){
	// Render the next frame
	RenderBabylon();    
    getAPLPhys();
	document.getElementById("step").innerHTML = "Step: " + step;
}

function Rnext() {
	StepOnce();
    Ttimer = setTimeout("Rnext()", frame_time); // Every 17ms
}

function stepScene() {
	// Get latest positions
	pos = posQueue.shift();
	step += dumpfreq;
	// Update particle positions
	SPS.updateParticle = updateParticle;
	SPS.setParticles();
}

var updateParticle = function(particle){
	var pid = particle.idx
	particle.position.x = pos[pid][0]*scale;
	particle.position.y = pos[pid][1]*scale;
	particle.position.z = pos[pid][2]*scale;
}

var createScene = function(engine) {
	// BJS Scene 
	var scene = new BABYLON.Scene(engine);
	// Scene optimisations https://doc.babylonjs.com/how_to/optimizing_your_scene
	//scene.autoClear = false; // Color buffer
	//scene.autoClearDepthAndStencil = false; // Depth and stencil, obviously
	//scene.blockMaterialDirtyMechanism = true; 
	//scene.useMaterialMeshMap = true;
    // Set up camera
	var camera = new BABYLON.ArcRotateCamera("Camera", 30, 1, 30, new BABYLON.Vector3(7, 5, 4), scene);
	camera.attachControl(canvas, true);
	// Create a basic light, aiming 0,1,0 - meaning, to the sky
	var light = new BABYLON.HemisphericLight('light1', new BABYLON.Vector3(0,1,0), scene);
	// Create a built-in "ground" shape;
	var ground = BABYLON.Mesh.CreateGround('ground1', scale, scale, 5, scene);
	ground.position = new BABYLON.Vector3((scale/2),0,(scale/2));
	var groundmesh = new BABYLON.StandardMaterial("groundmesh", scene);
	groundmesh.wireframe = true;
	ground.material = groundmesh;
	// Get this frame's atom positions
	pos = posQueue[0];
	// Set up SPS
	SPS = new BABYLON.SolidParticleSystem("SPS", scene);
	var sphere = BABYLON.MeshBuilder.CreateSphere("s", {diameter:0.3, segments: 10}, scene);
	SPS.addShape(sphere, pos.length);      // 20 spheres
	sphere.dispose();
	var mesh = SPS.buildMesh();  // Build and display the mesh
	
	return scene;
}

function RenderBabylon() {
	if (posQueue.length === 0) {return;}
	stepScene();
	
}
