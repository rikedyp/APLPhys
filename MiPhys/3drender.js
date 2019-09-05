//https://playground.babylonjs.com/#LXXL6Y#1

var posQueue = [];
var groups = [];
var pos;
var reQueue = 0;
var playing=0;  
var playframe = 0;   
var pbmult = 1;
var scale = 12.0;
var SPS; // Atom Solid Particle System
var wallSPS; // Wall solid particle system
var step;
var dumpfreq;
var reTime = 0;
var frameTime = 17;
var rTimer;
var tTimer;

// Get canvas DOM
var canvas = document.getElementById("viewport");
var baby;
  
// Function attached to "Run script" button
async function wakeBaby() {
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

function babyMenu(){
  // Clear old form 
  const babySet = document.getElementById("babySet");
  while (babySet.firstChild) {
    babySet.removeChild(babySet.firstChild);
  }
  // Create render settings interface
  var table = document.createElement("table");
  var tr = document.createElement("tr");
  var td = document.createElement("td");
  var groupSelect = document.createElement("select");
  groupSelect.name = "groupSelect";
  groupSelect.id = "groupSelect";
  for (var i=0; i<groups.length; i++) {
    var option = document.createElement("option");
    if (i===0) {
      option.value = [0,groups[i]];
    } else {
      option.value = [groups[i-1], groups[i-1] + groups[i]];
    }
    option.innerHTML = (i+1) + " (" + groups[i] + ")";
    groupSelect.appendChild(option);
  }
  var p = document.createElement("p");
  p.innerHTML = "Atom group (number of atoms)";  
  td.appendChild(groupSelect);
  tr.appendChild(td);
  td = document.createElement("td");
  td.appendChild(p);
  tr.appendChild(td);
  table.appendChild(tr);
  var colSelect = document.createElement("input");
  colSelect.type = "color";
  colSelect.name = "colSelect";
  colSelect.id = "colSelect";
  colSelect.addEventListener("change", updateScene);
  colSelect.value = "#ffffff";
  p = document.createElement("p");
  p.innerHTML = "Atom colour";
  tr = document.createElement("tr");
  td = document.createElement("td");
  td.appendChild(colSelect);
  tr.appendChild(td);
  td = document.createElement("td");
  td.appendChild(p);
  tr.appendChild(td);
  table.appendChild(tr);  
  
  babySet.appendChild(document.createElement("br"));
  babySet.appendChild(table);
}

function updateScene() {
  // Update mesh and particle properties from the Render Settings
  SPS.updateParticle = newParticleColors;
  SPS.setParticles();
}

var newParticleColors = function(particle) {
  var pid = particle.idx;
  var color = document.getElementById("colSelect").value;
  var group = document.getElementById("groupSelect").value.split(",");
  if (group[0] <= pid && pid < group[1]) {
    particle.color = BABYLON.Color3.FromHexString(color);    
  }  
}

// Function attached to "Start/Stop" button 
function startStop(){
    if (!playing){
        pbmult = Number(document.getElementById("playspeed").value);
        Rnext();
        clearTimeout(rTimer);
    }
    else {
        clearTimeout(tTimer);
        frameBuffer();
    }
    playing = !playing;
}

// Perform callback to the server to get particle trajectories
function getAPLPhys(){
 // console.log(posQueue.length); // Print number of frames in queue
  return new Promise(function (resolve) {
    // Request up to 6 frames at a time, kep buffer ~ 600 frames
    if (reQueue < 6 && posQueue.length < 60000) {    
      reQueue+=1;
      var re_start_time = new Date().getTime();
      var data = new FormData();
      data.append("reTime", reTime);
      data.append("_callback", "Tick");
      var xhr = new XMLHttpRequest();
      xhr.open('POST', "/BrazilNut.mipage", true);
      xhr.setRequestHeader("isAPLJax", true);
      xhr.onreadystatechange = function() {               
        // On request success, work out request time and decrement request counter reQueue
        if (this.readyState == 4 && this.status == 200) {         
          reTime = new Date().getTime() - re_start_time;          
          APLJaxReturn(eval(this.responseText));
          resolve();
          reQueue-=1;
          document.getElementById("loaded").innerHTML = "Loaded: " + posQueue.length*dumpfreq;          
         }
      };                               
      xhr.send(data);
    }
  });
}

function stepOnce(){
  // Render the next frame
  stepScene(); 
  getAPLPhys();
  document.getElementById("step").innerHTML = "Step: " + step;
}

function stepScene() {
  if (posQueue.length === 0) {return;}
  if (playframe > posQueue.length) {startStop();return;}
  // Get latest positions, update step counter
  pos = posQueue[playframe];
  wallmove = wallQueue[playframe];
  playframe += pbmult;
  step += dumpfreq*pbmult;
  // Update particle positions in Babylon SolidParticleSystem
  SPS.updateParticle = updateParticle;
  SPS.setParticles();
  // Update wall positions in scene 
  wallSPS.updateParticle = updateWalls;
  wallSPS.setParticles();
}

function reStart(){
  playframe = 0;
  step = 0;
  document.getElementById("step").innerHTML = "Step: " + step;
}

function Rnext() {
  stepOnce();
  tTimer = setTimeout("Rnext()", frameTime); // Every frameTime milliseconds
}

function frameBuffer() {
  getAPLPhys();
  rTimer = setTimeout("frameBuffer()", 100);
}

var updateParticle = function(particle){
  var pid = particle.idx
  particle.position.x = pos[pid][0]*scale;
  particle.position.y = pos[pid][1]*scale;
  particle.position.z = pos[pid][2]*scale;
}

var updateWalls = function(wall){
  var wid = wall.idx;
  wall.position.x -= wallmove[wid][0]*scale;
  wall.position.y -= wallmove[wid][1]*scale;
  wall.position.z -= wallmove[wid][2]*scale;
}

var createScene = function(engine) {
  var scene = new BABYLON.Scene(engine);
  scene.clearColor = new BABYLON.Color3(.8, .8, .8);
    // Set up camera
  var camera = new BABYLON.ArcRotateCamera("Camera", 30, 1, 30, new BABYLON.Vector3(7, 5, 4), scene);
  camera.attachControl(canvas, true);
  // Create a basic light, aiming 0,1,0 - meaning, to the sky
  var light = new BABYLON.HemisphericLight('light1', new BABYLON.Vector3(0,1,0), scene);
  // Create a built-in "ground" shape;
  var ground = BABYLON.Mesh.CreateGround('ground1', scale*10, scale*10, 20, scene);
  ground.position = new BABYLON.Vector3((scale/2),0,(scale/2));
  var groundmesh = new BABYLON.StandardMaterial("groundmesh", scene);
  groundmesh.wireframe = true;
  ground.material = groundmesh;
  // Create APLPhys walls 
  wallSPS = new BABYLON.SolidParticleSystem("babywalls", scene);
  var wallPos = [];
  var wallPlanes = [];
  for (var i=0; i<walls.length; i++){
    var sourcePlane = new BABYLON.Plane(walls[i][0], walls[i][1], walls[i][2], walls[i][3]*scale);
    sourcePlane.normalize();
    wallPlanes.push(sourcePlane);
    var wall = BABYLON.MeshBuilder.CreatePlane("plane", {height:50, width: 50, sourcePlane: sourcePlane, sideOrientation: BABYLON.Mesh.DOUBLESIDE}, scene);
    
    //wall.material = new BABYLON.StandardMaterial("wallGrid", scene);
    //var col = ((1+i)/walls.length);
    //wall.material.diffuseColor = new BABYLON.Color3(col*0.5,1-col,col);
    //wall.material.alpha = 0.5;
    wallSPS.addShape(wall, 1);
    wallPos.push(wall.position);
    wall.dispose();
  }
  //wallSPS.hasVertexAlpha = true;
  var wallmesh = wallSPS.buildMesh();
  wallmesh.hasVertexAlpha = true;
  var pi = 1.57;
  var numwalls = wallSPS.particles.length;
  wallSPS.updateParticle = function(wall){
    wid = wall.idx;
    var col = (1+wid)/numwalls;
    console.log(wallPlanes[wid].normal);
    //wall.rotation.x = pi;
    wall.rotation.x = wallPlanes[wid].normal.y*pi;
    wall.rotation.y = wallPlanes[wid].normal.x*pi;
    wall.rotation.z = wallPlanes[wid].normal.z*pi;
    wall.position = wallPos[wid];
    wall.color.r = col*0.2;
    wall.color.g = 0.8*col;
    wall.color.b = 0.5*1-col;
    wall.color.a = 0.4;
  }
  wallSPS.setParticles();
  // Get this frame's atom positions
  pos = posQueue[0];
  // Set up SPS
  SPS = new BABYLON.SolidParticleSystem("SPS", scene);
  //var sphere = BABYLON.MeshBuilder.CreateSphere("s", {diameter:0.3, segments: 10}, scene);
  for (var i=0; i<groups.length; i++){
    var sphere = BABYLON.MeshBuilder.CreateSphere("s", {diameter: radii[i]*scale, segments: 10}, scene);
    SPS.addShape(sphere, groups[i]);
    sphere.dispose();
  }
  //SPS.addShape(sphere, pos.length);      // 20 spheres
  //sphere.dispose();
  var mesh = SPS.buildMesh();  // Build and display the mesh
  
  return scene;
}
