var requestAnimFrame = window.requestAnimationFrame || window.webkitRequestAnimationFrame ||
                       window.mozRequestAnimationFrame || window.msRequestAnimationFrame || 
                       function(c) {window.setTimeout(c, 15)};
/**
   Phoria
   pho·ri·a (fôr-)
   n. The relative directions of the eyes during binocular fixation on a given object
*/

// bind to window onload event
//window.addEventListener('load', onloadHandler, false);

function onloadHandler()
{
   // get the canvas DOM element and the 2D drawing context
   var canvas = document.getElementById('viewport');
   
   // create the scene and setup camera, perspective and viewport
   var scene = new Phoria.Scene();
   scene.camera.position = {x:0.0, y:5.0, z:-15.0};
   scene.perspective.aspect = canvas.width / canvas.height;
   scene.viewport.width = canvas.width;
   scene.viewport.height = canvas.height;
   
   // create a canvas renderer
   var renderer = new Phoria.CanvasRenderer(canvas);
   
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
   //var c = Phoria.Util.generateUnitCube();
   //var cube = Phoria.Entity.create({
   //   points: c.points,
   //   edges: c.edges,
   //   polygons: c.polygons
   // });
   // scene.graph.push(cube);
   // scene.graph.push(new Phoria.DistantLight());

   var pause = false;
   var fnAnimate = function() {
      if (!pause)
      {
         // rotate local matrix of the cube
         //cube.rotateY(0.5*Phoria.RADIANS);
         
         // execute the model view 3D pipeline and render the scene
         scene.modelView();
         renderer.render(scene);
      }
      requestAnimFrame(fnAnimate);
   };

   // key binding
   document.addEventListener('keydown', function(e) {
      switch (e.keyCode)
      {
         case 27: // ESC
            pause = !pause;
            break;
      }
   }, false);
   
   // start animation
   requestAnimFrame(fnAnimate);
}