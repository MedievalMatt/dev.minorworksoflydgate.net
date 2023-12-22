const elem = document.getElementById('3d-graph');

const Graph = ForceGraph3D()
	(elem)
	.nodeLabel('name')
	.nodeOpacity('1')
	.nodeResolution('100')
	.nodeRelSize('10')
	.onNodeClick(node => {
          // Aim at node from outside it
          const distance = 40;
          const distRatio = 1 + distance/Math.hypot(node.x, node.y, node.z);
          Graph.cameraPosition(
            { x: node.x * distRatio, y: node.y * distRatio, z: node.z * distRatio }, // new position
            node, // lookAt ({ x, y, z })
            3000  // ms transition duration
          );
        });

      // Add collisionforces
      Graph.d3Force('collide', d3.forceCollide(Graph.nodeRelSize()))
           .d3Force('charge').strength(-150);



let curDataSetIdx,
	numDim = 3;

const dataSets = getGraphDataSets();

let toggleData;
(toggleData = function() {
	curDataSetIdx = curDataSetIdx === undefined ? 0 : (curDataSetIdx+1)%dataSets.length;

	const dataSet = dataSets[curDataSetIdx];
	document.getElementById('graph-data-description').innerHTML = dataSet.description ? `Viewing ${dataSet.description}` : '';

	dataSet(Graph
		.resetProps()
		.enableNodeDrag(false)
		.numDimensions(numDim)
	);
})(); // IIFE init

const toggleDimensions = function(numDimensions) {
	numDim = numDimensions;
	Graph.numDimensions(numDim);
};