import * as THREE from "../build/three.module.js";
import {
    DDSLoader
}
    from "./jsm/loaders/DDSLoader.js";
import {
    MTLLoader
}
    from "./jsm/loaders/MTLLoader.js";
import {
    OBJLoader
}
    from "./jsm/loaders/OBJLoader.js";
console.log("all loaded");
var OBJFile = "test/clopton_chapel.obj";
var MTLFIle = "test/clopton_chapel.mtl";
var JPGFile = "test/clopton_chapel.jpg";
import {
    PointerLockControls
}
    from './jsm/controls/PointerLockControls.js';
var camera, scene, renderer, controls;
var canvas = document.getElementById('canvas');
var scene = new THREE.Scene();
var renderer = new THREE.WebGLRenderer();
canvas.appendChild(renderer.domElement);
var raycaster;
var store_mouse;
var moveForward = false;
var moveBackward = false;
var moveLeft = false;
var moveRight = false;
var moveUp = false;
var moveDown = false;
var canJump = false;
var cameraPosition = false;
var prevTime = performance.now();
var velocity = new THREE.Vector3();
var mouse = new THREE.Vector2();
var direction = new THREE.Vector3();
var vertex = new THREE.Vector3();
var initialX;
var initialY;
var initialZ;
var cameraX;
var cameraY;
var cameraZ;
document.addEventListener('mousemove', onDocumentMouseMove, false);
var oldURL = document.referrer;
console.log(oldURL);
switch (oldURL) {
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.3&surface=p.1":
        initialX = -8.519834975632183;
        initialY = 7.283545153115464;
        initialZ = -8.292318908793906;
        cameraX = -8.496115776030335;
        cameraY = -2;
        cameraZ = -3.04835674670682;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.3&surface=p.2":
        initialX = -6.825867298930372;
        initialY = 7.2102602800389715;
        initialZ = -8.258583964829535;
        cameraX = -6.80233534014048;
        cameraY = -2;
        cameraZ = -3.0560179606894504;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.3&surface=p.3":
        initialX = -5.113789194600154;
        initialY = 7.158193351758799;
        initialZ = -8.236916484949862;
        cameraX = -5.090390265363538;
        cameraY = -2;
        cameraZ = -3.0637613359619893;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.3&surface=p.4":
        initialX = -3.3059169601471923;
        initialY = 7.0935608524931215;
        initialZ = -8.208584282488935;
        cameraX = -3.28268316514815;
        cameraY = -2;
        cameraZ = -3.071937856731281;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.3&surface=p.5":
        initialX = -1.6337809338346516;
        initialY = 6.987458587329337;
        initialZ = -8.238216527882695;
        cameraX = -1.5081299050350037;
        cameraY = -2;
        cameraZ = -3.1154641540262507;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.3&surface=p.6":
        initialX = 0.13022290021609212;
        initialY = 6.910869413709301;
        initialZ = -8.237802819500075;
        cameraX = 0.25480315818917526;
        cameraY = -2;
        cameraZ = -3.158705430772226;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.3&surface=p.7":
        initialX = 1.8984550894127143;
        initialY = 6.849713130988398;
        initialZ = -8.246294694356221;
        cameraX = 2.022180339291265;
        cameraY = -2;
        cameraZ = -3.2020557129790785;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.4&surface=p.1":
        initialX = 3.4357481110069497;
        initialY = 7.077646319379133;
        initialZ = -7.51256985767517;
        cameraX = -5.369849501440076;
        cameraY = -2;
        cameraZ = -7.483340091760531;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.4&surface=p.2":
        initialX = 3.436096985598435;
        initialY = 7.255876526763288;
        initialZ = -5.887944667892925;
        cameraX = -5.364456690334095;
        cameraY = -2;
        cameraZ = -5.858731645087624;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.4&surface=p.3":
        initialX = 3.449920056335043;
        initialY = 7.452356338961309;
        initialZ = -4.295331494480909;
        cameraX = -5.358973771876992;
        cameraY = -2;
        cameraZ = -4.230854167574048;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.4&surface=p.4":
        initialX = 3.4868163578223674;
        initialY = 7.475341723363263;
        initialZ = -2.181207239871815;
        cameraX = -5.343498140912092;
        cameraY = -2;
        cameraZ = -2.11657312283866;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.4&surface=p.5":
        initialX = 3.4895377882635685;
        initialY = 7.277403491734221;
        initialZ = -0.514106834418738;
        cameraX = -5.331296188473235;
        cameraY = -2;
        cameraZ = -0.4495421107428114;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.4&surface=p.6":
        initialX = 3.5237655886746824;
        initialY = 7.117970934379448;
        initialZ = 1.1209368566491145;
        cameraX = -5.320492400492651;
        cameraY = -2;
        cameraZ = 1.0264716421364386;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Quis_Dabit&filename=Clopton_Quis_Dabit&surfaceGrp=w.4&surface=p.1":
        initialX = 3.517912661347138;
        initialY = 1.1844368212197425;
        initialZ = -6.7339841205962605;
        cameraX = -5.2401665391734;
        cameraY = -2;
        cameraZ = -6.985239626904974;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Quis_Dabit&filename=Clopton_Quis_Dabit&surfaceGrp=w.4&surface=p.2":
        initialX = 3.5086827073153435;
        initialY = 1.1984373463637894;
        initialZ = -5.068959030344616;
        cameraX = -5.28790179726504;
        cameraY = -2;
        cameraZ = -5.321319193216218;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Quis_Dabit&filename=Clopton_Quis_Dabit&surfaceGrp=w.4&surface=p.3":
        initialX = 3.483345764569404;
        initialY = 1.2069554553327908;
        initialZ = -3.3685042154132003;
        cameraX = -5.3366658880994775;
        cameraY = -2;
        cameraZ = -3.62153646628716;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Quis_Dabit&filename=Clopton_Quis_Dabit&surfaceGrp=w.4&surface=p.4":
        initialX = 3.506093221218511;
        initialY = 1.152910226469182;
        initialZ = -1.6388319993815954;
        cameraX = -5.386227948730721;
        cameraY = -2;
        cameraZ = -1.8939386964850575;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Quis_Dabit&filename=Clopton_Quis_Dabit&surfaceGrp=w.4&surface=p.5":
        initialX = 3.539184816799378;
        initialY = 1.1815560203225393;
        initialZ = 0.02616561272543541;
        cameraX = -5.433927616083298;
        cameraY = -2;
        cameraZ = -0.2312588585393329;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Quis_Dabit&filename=Clopton_Quis_Dabit&surfaceGrp=w.4&surface=p.6":
        initialX = 3.548979633128474;
        initialY = 1.2012972329514424;
        initialZ = 1.6270970933644797;
        cameraX = -5.4798099964935;
        cameraY = -2;
        cameraZ = 1.36807533096586;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.1&surface=p.1":
        initialX = 2.2451172472376415;
        initialY = 6.8879590392656205;
        initialZ = 2.3730725193600564;
        cameraX = 2.52442645351949;
        cameraY = -2;
        cameraZ = -2.805415043845714;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.1&surface=p.2":
        initialX = 0.8088985162727673;
        initialY = 6.9589434708077995;
        initialZ = 2.3370867311191015;
        cameraX = 1.090438448995278;
        cameraY = -2;
        cameraZ = -2.8827592580535786;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.1&surface=p.3":
        initialX = -1.0500914762930051;
        initialY = 7.045052211740039;
        initialZ = 2.2871455734614616;
        cameraX = -0.818559025435806;
        cameraY = -2;
        cameraZ = -2.9854497948890617;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.1&surface=p.4":
        initialX = -2.660583191379256;
        initialY = 7.105314764139665;
        initialZ = 2.2516213183746427;
        cameraX = -2.4275081583317752;
        cameraY = -2;
        cameraZ = -3.056102653684199;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.1&surface=p.5":
        initialX = -4.417880334837504;
        initialY = 7.171159026915488;
        initialZ = 2.21291047867061;
        cameraX = -4.1831198407027355;
        cameraY = -2;
        cameraZ = -3.1331958207443606;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.1&surface=p.6":
        initialX = -6.092168453866942;
        initialY = 7.248781679095583;
        initialZ = 2.184723934599897;
        cameraX = -5.855420999073399;
        cameraY = -2;
        cameraZ = -3.2066306206330593;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.1&surface=p.7":
        initialX = -8.809400799895778;
        initialY = 7.340334181646467;
        initialZ = 2.194323271390474;
        cameraX = -8.555963001443944;
        cameraY = -2;
        cameraZ = -3.325217969892757;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.2&surface=p.1":
        initialX = -10.3204072257629;
        initialY = 7.554191319916642;
        initialZ = 1.477578477910352;
        cameraX = -0.04300121376229044;
        cameraY = -2;
        cameraZ = 1.0980455115551067;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.2&surface=p.2":
        initialX = -10.32066237028896;
        initialY = 7.728397574126932;
        initialZ = -0.19057564485769585;
        cameraX = -0.10527524994505058;
        cameraY = -2;
        cameraZ = -0.5882784987244591;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.2&surface=p.3":
        initialX = -10.301863329892495;
        initialY = 7.922651814612621;
        initialZ = -1.8661873256020554;
        cameraX = -0.17038256258568601;
        cameraY = -2;
        cameraZ = -2.260623558667551;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.2&surface=p.4":
        initialX = -10.355873258764458;
        initialY = 7.901469395343003;
        initialZ = -3.809869187726648;
        cameraX = -0.24602070914026217;
        cameraY = -2;
        cameraZ = -4.20346339652081;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.2&surface=p.5":
        initialX = -10.405496811527984;
        initialY = 7.726300513080481;
        initialZ = -5.563216155760586;
        cameraX = -0.31425336201384;
        cameraY = -2;
        cameraZ = -5.956085879801073;
        break;
    case "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.2&surface=p.6":
        initialX = -10.413425237744725;
        initialY = 7.55478298910486;
        initialZ = -7.263072906218896;
        cameraX = -0.3803435980542073;
        cameraY = -2;
        cameraZ = -7.6536782894683375;
        break;
    default:

        initialX = -9.798724676415432;
        initialY = 7.443706228158007;
        initialZ = -8.261494198041225;
        cameraX = 4.431908726702628;
        cameraY = -2;
        cameraZ = -0.43551482007734554;


}

/*fetch("../../../resources/javascript/panels.json")
    .then((response) => response.json())
    .then((json) => console.log(json));
    
    console.log(json);*/

var panels = [
    {
        wall: "south",
        poem: "Testament",
        panel: 1,
        x_min: -9.434993069,
        x_max: -7.616428919,
        y_min: 6.939507666,
        y_max: 7.739160761,
        z_min: -8.66692426,
        z_max: -7.959837328,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.3&surface=p.1"
    },
    {
        wall: "south",
        poem: "Testament",
        panel: 2,
        x_min: -7.720052204,
        x_max: -5.856337529,
        y_min: 6.896966603,
        y_max: 7.687645667,
        z_min: -8.560184831,
        z_max: -8.025525816,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.3&surface=p.2"
    },
    {
        wall: "south",
        poem: "Testament",
        panel: 3,
        x_min: -5.999559735,
        x_max: -4.148694221,
        y_min: 6.839440271,
        y_max: 7.564946964,
        z_min: -8.637342877,
        z_max: -7.931446039,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.3&surface=p.3"
    },
    {
        wall: "south",
        poem: "Testament",
        panel: 4,
        x_min: -4.15156755,
        x_max: -2.411381726,
        y_min: 6.7269025051,
        y_max: 7.509601905,
        z_min: -8.51390833,
        z_max: -7.974416201,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.3&surface=p.4"
    },
    {
        wall: "south",
        poem: "Testament",
        panel: 5,
        x_min: -2.478782269,
        x_max: -0.597890446,
        y_min: 6.634355478,
        y_max: 7.428274023,
        z_min: -8.630597469,
        z_max: -7.94008589,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.3&surface=p.5"
    },
    {
        wall: "south",
        poem: "Testament",
        panel: 6,
        x_min: -0.700249575,
        x_max: 1.129966741,
        y_min: 6.580908145,
        y_max: 7.333844784,
        z_min: -8.606216582,
        z_max: -7.936830268,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.3&surface=p.6"
    },
    {
        wall: "south",
        poem: "Testament",
        panel: 7,
        x_min: 1.042623527,
        x_max: 2.879225406,
        y_min: 6.527518564,
        y_max: 7.255801771,
        z_min: -8.549107691,
        z_max: -7.9347254,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.3&surface=p.7"
    },
    {
        wall: "west",
        poem: "Testament",
        panel: 1,
        x_min: 3.274992928,
        x_max: 3.549081461,
        y_min: 6.711754469,
        y_max: 7.669329524,
        z_min: -8.421000224,
        z_max: -6.496351069,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.4&surface=p.1"
    },
    {
        wall: "west",
        poem: "Testament",
        panel: 2,
        x_min: 3.30964863,
        x_max: 3.557049216,
        y_min: 6.880693323,
        y_max: 7.841001981,
        z_min: -6.794846323,
        z_max: -4.841774373,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.4&surface=p.2"
    },
    {
        wall: "west",
        poem: "Testament",
        panel: 3,
        x_min: 3.34479882,
        x_max: 3.583352167,
        y_min: 7.02088417,
        y_max: 8.003519898,
        z_min: -5.079093759,
        z_max: -3.325459416,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.4&surface=p.3"
    },
    {
        wall: "west",
        poem: "Testament",
        panel: 4,
        x_min: 3.411387242,
        x_max: 3.662657058,
        y_min: 7.069601093,
        y_max: 7.992751892,
        z_min: -3.039206849,
        z_max: -1.368816942,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.4&surface=p.4"
    },
    {
        wall: "west",
        poem: "Testament",
        panel: 5,
        x_min: 3.448485521,
        x_max: 3.647091143,
        y_min: 6.876904346,
        y_max: 7.831714093,
        z_min: -1.345566346,
        z_max: 0.217887417,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.4&surface=p.5"
    },
    {
        wall: "west",
        poem: "Testament",
        panel: 6,
        x_min: 3.450833164,
        x_max: 3.655307148,
        y_min: 6.701710991,
        y_max: 7.6571051,
        z_min: 0.266329778,
        z_max: 1.884200013,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.4&surface=p.6"
    },
    {
        wall: "west",
        poem: "Quis Dabit",
        panel: 1,
        x_min: 3.429237476,
        x_max: 3.641410806,
        y_min: 0.718853024,
        y_max: 1.574107039,
        z_min: -7.649938518,
        z_max: -5.78613756,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Quis_Dabit&filename=Clopton_Quis_Dabit&surfaceGrp=w.4&surface=p.1"
    },
    {
        wall: "west",
        poem: "Quis Dabit",
        panel: 2,
        x_min: 3.419978712,
        x_max: 3.65040502,
        y_min: 0.694241412,
        y_max: 1.681901191,
        z_min: -5.960931141,
        z_max: -4.158716575,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Quis_Dabit&filename=Clopton_Quis_Dabit&surfaceGrp=w.4&surface=p.2"
    },
    {
        wall: "west",
        poem: "Quis Dabit",
        panel: 3,
        x_min: 3.419644732,
        x_max: 3.672377659,
        y_min: 0.702350887,
        y_max: 1.682411531,
        z_min: -4.193621233,
        z_max: -2.439698858,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Quis_Dabit&filename=Clopton_Quis_Dabit&surfaceGrp=w.4&surface=p.3"
    },
    {
        wall: "west",
        poem: "Quis Dabit",
        panel: 4,
        x_min: 3.427082658,
        x_max: 3.677545264,
        y_min: 0.69390356,
        y_max: 1.684449607,
        z_min: -2.589016889,
        z_max: -0.647988025,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Quis_Dabit&filename=Clopton_Quis_Dabit&surfaceGrp=w.4&surface=p.4"
    },
    {
        wall: "west",
        poem: "Quis Dabit",
        panel: 5,
        x_min: 3.430045947,
        x_max: 3.688891426,
        y_min: 0.733984184,
        y_max: 1.580459248,
        z_min: -0.864330561,
        z_max: 0.909595517,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Quis_Dabit&filename=Clopton_Quis_Dabit&surfaceGrp=w.4&surface=p.5"
    },
    {
        wall: "west",
        poem: "Quis Dabit",
        panel: 6,
        x_min: 3.454363937,
        x_max: 3.701713414,
        y_min: 0.71935146,
        y_max: 1.605622553,
        z_min: 0.800778985,
        z_max: 2.459269525,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Quis_Dabit&filename=Clopton_Quis_Dabit&surfaceGrp=w.4&surface=p.6"
    },
    {
        wall: "north",
        poem: "Testament",
        panel: 1,
        x_min: 1.522750251,
        x_max: 3.328853378,
        y_min: 6.607274832,
        y_max: 7.300809313,
        z_min: 2.010197438,
        z_max: 2.711209521,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.1&surface=p.1"
    },
    {
        wall: "north",
        poem: "Testament",
        panel: 2,
        x_min: -0.164165118,
        x_max: 1.593280382,
        y_min: 6.686826489,
        y_max: 7.326108936,
        z_min: 2.003915195,
        z_max: 2.69781317,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.1&surface=p.2"
    },
    {
        wall: "north",
        poem: "Testament",
        panel: 3,
        x_min: -1.843827124,
        x_max: -0.105900892,
        y_min: 6.726040901,
        y_max: 7.387508278,
        z_min: 1.988805698,
        z_max: 2.678024316,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.1&surface=p.3"
    },
    {
        wall: "north",
        poem: "Testament",
        panel: 4,
        x_min: -3.557178123,
        x_max: -1.735544337,
        y_min: 6.754862461,
        y_max: 7.445150446,
        z_min: 1.971919022,
        z_max: 2.641049384,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.1&surface=p.4"
    },
    {
        wall: "north",
        poem: "Testament",
        panel: 5,
        x_min: -5.221142377,
        x_max: -3.490788138,
        y_min: 6.858386679,
        y_max: 7.509049499,
        z_min: 1.939754108,
        z_max: 2.615543936,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.1&surface=p.5"
    },
    {
        wall: "north",
        poem: "Testament",
        panel: 6,
        x_min: -6.955466989,
        x_max: -5.208702424,
        y_min: 6.90603358,
        y_max: 7.549189688,
        z_min: 1.927988994,
        z_max: 2.583997558,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.1&surface=p.6"
    },
    {
        wall: "north",
        poem: "Testament",
        panel: 7,
        x_min: -9.725450149,
        x_max: -7.968151904,
        y_min: 7.018650781,
        y_max: 7.663041768,
        z_min: 1.87961196,
        z_max: 2.576023298,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.1&surface=p.7"
    },
    {
        wall: "east",
        poem: "Testament",
        panel: 1,
        x_min: -10.60196012,
        x_max: -10.17092125,
        y_min: 7.172222666,
        y_max: 8.081780417,
        z_min: 0.641089114,
        z_max: 2.188542588,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.2&surface=p.1"
    },
    {
        wall: "east",
        poem: "Testament",
        panel: 2,
        x_min: -10.58622828,
        x_max: -10.14378026,
        y_min: 7.295502888,
        y_max: 8.281485109,
        z_min: -1.057681059,
        z_max: 0.541430677,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.2&surface=p.2"
    },
    {
        wall: "east",
        poem: "Testament",
        panel: 3,
        x_min: -10.56967034,
        x_max: -10.15714815,
        y_min: 7.482912926,
        y_max: 8.429300517,
        z_min: -2.69119887,
        z_max: -1.144819182,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.2&surface=p.3"
    },
    {
        wall: "east",
        poem: "Testament",
        panel: 4,
        x_min: -10.58844408,
        x_max: -10.15391563,
        y_min: 7.533516222,
        y_max: 8.404471085,
        z_min: -4.692256863,
        z_max: -3.035807867,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.2&surface=p.4"
    },
    {
        wall: "east",
        poem: "Testament",
        panel: 5,
        x_min: -10.63539383,
        x_max: -10.203007993,
        y_min: 7.360214616,
        y_max: 8.265438816,
        z_min: -6.285458226,
        z_max: -4.748122497,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.2&surface=p.5"
    },
    {
        wall: "east",
        poem: "Testament",
        panel: 6,
        x_min: -10.67729908,
        x_max: -10.18217204,
        y_min: 7.15223172,
        y_max: 8.092551603,
        z_min: -7.937139243,
        z_max: -6.467732743,
        url: "http://localhost:8080/exist/apps/mwjl-app/index?folder=texts&work_folder=Testament&filename=Clopton_Testament&surfaceGrp=w.2&surface=p.6"
    }];
init();
animate();

function windowFunction(e) {
    //console.log(window.p);
    console.log(panels[e.currentTarget.p].url);
    //console.log(url);
    console.log(clickthrough.style.display);
    if (controls.isLocked) {
        if (clickthrough.style.display != "block") { }
        else {
            console.log("block detected");
            window.location.href = panels[e.currentTarget.p].url;
        }
    }
};



function init() {
    var blocker = document.getElementById('blocker');
    var instructions = document.getElementById('instructions');
    camera = new THREE.PerspectiveCamera(45, window.innerWidth / window.innerHeight,
        1, 1000);
    camera.position.set(cameraX, cameraY, cameraZ);
    scene = new THREE.Scene();
    camera.lookAt(initialX, initialY, initialZ);
    //var progressElem = document.getElementById("progressBar");
    //console.log(progressElem);
    
    var testProgress = function(xhr) {
        console.log(xhr);
    }
    
    var onProgress = function (xhr) {
        if (xhr.lengthComputable) {
            var percentComplete = xhr.loaded / xhr.total * 100;
            //var instructOneElem = document.getElementById("instruction_text_one");
            var barWidth = 0;

            barWidth = barWidth + Math.round(percentComplete, 2);
            console.log(barWidth);
            progressElem.style.width = barWidth + "%";
            progressElem.innerHTML = barWidth + "%";

            if (barWidth >= 100) {
                progressElem.innerHTML = "Initializing Model. Please wait for the image to appear completely before clicking.";
            }

            console.log(Math.round(percentComplete, 2) + '% downloaded');
        }
    };
    var onError = function () {
        console.log("error thrown")
    };
    var manager = new THREE.LoadingManager();
    manager.addHandler(/\.dds$/i, new DDSLoader());
    
    manager.onStart = function (item, loaded, total) {
        console.log('Loading started');
    };

    manager.onLoad = function () {
        console.log('Loading complete');            
    //    bar.destroy();
    };


    var progressElem = document.getElementById("progressBar");
    manager.onProgress = function (item, loaded, total) {            
        console.log(item, loaded, total);
        console.log('Loaded:', Math.round(loaded / total * 100, 2) + '%');
        
        var barWidth = 0;

        barWidth = barWidth + Math.round(loaded / total * 100, 2);
        //console.log(barWidth);
        progressElem.style.width = barWidth + "%";
        progressElem.innerHTML = barWidth + "%";

        if (barWidth >= 100) {
            progressElem.innerHTML = "Initializing Model. Please wait for the image to appear completely before clicking.";
        }
    //    bar.animate(1.0);
    };

    manager.onError = function (url) {
        console.log('Error loading');
    };
    
    new MTLLoader(manager)
        //.setPath( 'test/' )
        .load(MTLFIle, function (materials) {
            materials.preload();
            new OBJLoader(manager).setMaterials(materials)
                //.setPath( 'test/' )
                .load(OBJFile, function (object) {
                    var texture = new THREE.TextureLoader().load(JPGFile);
                    texture.minFilter = THREE.NearestFilter;
                    object.traverse(function (child) { // aka setTexture
                        if (child instanceof THREE.Mesh) {
                            child.material.map = texture;
                        }
                    });
                    //bbox = new THREE.Box3().setFromObject(object);
                    //console.log(bbox);
                    scene.add(object);
                }, onProgress, onError);
        });
    scene.background = new THREE.Color(0x084c8d);
    var ambient = new THREE.AmbientLight(0xFFFFFF);
    scene.add(ambient);
    var hemisphereLight = new THREE.HemisphereLight(0xffffff, 0xffffff, .70);
    scene.add(hemisphereLight);
    controls = new PointerLockControls(camera, document.body);
    scene.add(controls.getObject());
    instructions.addEventListener('click', function () {
        controls.lock();
        onDocumentMouseMove(event);
    }, false);
    controls.addEventListener('lock', function () {
        instructions.style.display = 'none';
        progress.style.display = 'none';
        progressBar.style.display = 'none';
        //instructionOneElem.style.display = 'none';
        blocker.style.display = 'none';
    });
    controls.addEventListener('unlock', function () {
        blocker.style.display = 'block';
        instructions.style.height = '100vh';
        instructions.style.display = '';
    });

    //console.log(bbox);
    var onKeyDown = function (event) {
        switch (event.keyCode) {
            case 38: // up
            case 87: // w
                moveForward = true;
                break;
            case 37: // left
            case 65: // a
                moveLeft = true;
                break;
            case 40: // down
            case 83: // s
                moveBackward = true;
                break;
            case 39: // right
            case 68: // d
                moveRight = true;
                break;
            case 85: // up
                moveUp = true;
                break;
            case 78: // down
                moveDown = true;
                break;
            case 67: // c is for oordinate capture.
                console.log(camera.position);
                var ray_direction = new THREE.Vector3();
                var ray = new THREE.Raycaster(); // create once and reuse
                controls.getDirection(ray_direction);
                ray.set(controls.getObject().position, ray_direction);
                var intersects = ray.intersectObjects(scene.children, true);
                for (var q = 0; q < intersects.length; q++) {
                    if (intersects[q].faceIndex !== null) {
                        console.log(intersects[q]);
                        console.log("index is " + q);
                        console.log("point");
                        console.log(intersects[q].point);
                        break;
                    }
                }
                break;
        }
    };
    var onKeyUp = function (event) {
        switch (event.keyCode) {
            case 38: // up
            case 87: // w
                moveForward = false;
                break;
            case 37: // left
            case 65: // a
                moveLeft = false;
                break;
            case 40: // down
            case 83: // s
                moveBackward = false;
                break;
            case 67: // c is for capture
                cameraPosition = false;
                break;
            case 39: // right
            case 68: // d
                moveRight = false;
                break;
            case 85: // up
                moveUp = false;
                break;
            case 78: // down
                moveDown = false;
                break;
        }
    };
    document.addEventListener('keydown', onKeyDown, false);
    document.addEventListener('keyup', onKeyUp, false);
    raycaster = new THREE.Raycaster(new THREE.Vector3(), new THREE.Vector3(
        0, -1, 0), 0, 10);
    // floor
    var floorGeometry = new THREE.PlaneBufferGeometry(2000, 2000, 100, 100);
    floorGeometry.rotateX(-Math.PI);
    // vertex displacement
    var position = floorGeometry.attributes.position;
    for (var i = 0, l = position.count; i < l; i++) {
        vertex.fromBufferAttribute(position, i);
        vertex.x += Math.random() * 20 - 10;
        vertex.y += Math.random() * 2;
        vertex.z += Math.random() * 20 - 10;
        position.setXYZ(i, vertex.x, vertex.y, vertex.z);
    }

    renderer.setPixelRatio(window.devicePixelRatio);
    renderer.setSize(window.innerWidth, window.innerHeight);

    window.addEventListener('resize', onWindowResize, true);
}

function raycast() {
    var clickthrough = document.getElementById('clickthrough');



    clickthrough.style.display = 'none';

    var ray_direction = new THREE.Vector3();
    var ray = new THREE.Raycaster(); // create once and reuse
    controls.getDirection(ray_direction);
    ray.set(controls.getObject().position, ray_direction);
    var intersects = ray.intersectObjects(scene.children, true);
    var intersect;
    for (var i = 0; i < intersects.length; i++) {
        if (intersects[i].faceIndex !== null) {
            intersect = intersects[i];
        }
        for (var p = 0; p < panels.length; p++) {
            if (intersect.point.x <= panels[p].x_max && intersect.point.x >= panels[p].x_min) {
                if (intersect.point.y <= panels[p].y_max && intersect.point.y >= panels[p].y_min) {
                    if (intersect.point.z <= panels[p].z_max && intersect.point.z >= panels[p].z_min) {
                        clickthrough.innerHTML = panels[p].wall.charAt(0).toUpperCase() +
                            panels[p].wall.slice(1) + " Wall, " + "Panel " + panels[p].panel + ": " + panels[p].poem;
                        clickthrough.style.display = 'block';

                        if (controls.isLocked) {
                            console.log('controls locked');
                            if (clickthrough.style.display === 'none') {
                                window.removeEventListener('click', windowFunction, true);
                            }
                            else {
                                window.p = p;
                                window.addEventListener('click', windowFunction, true);
                            }
                        }
                        else {
                            console.log('controls unlocked');
                            window.removeEventListener('click', windowFunction, true);
                        }
                        break;
                    }
                    else {
                        clickthrough.style.display = 'none';
                    }
                }
                else {
                    clickthrough.style.display = 'none';
                }
            }
            else {
                clickthrough.style.display = 'none';
            }
        }
    }
}

function onWindowResize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
}

function storeMousePos(event) {
    return mouse;
}

function onDocumentMouseMove(event) {
    store_mouse = storeMousePos(event);
    raycast();

}

function animate() {
    requestAnimationFrame(animate);
    if (controls.isLocked === true) {
        //console.log(raycaster);
        raycaster.ray.origin.copy(controls.getObject().position);
        var intersections = raycaster.intersectObjects(scene.children, true);
        //console.log(intersections);
        //console.log(intersections[distance]);
        //console.log(raycaster[distance]);
        var onObject = intersections.length > 0;
        var time = performance.now();
        var delta = (time - prevTime) / 1000;
        var position_x = camera.position.x;
        var position_z = camera.position.z;
        var position_y = camera.position.y;
        velocity.x -= velocity.x * 10.0 * delta;
        velocity.z -= velocity.z * 10.0 * delta;
        velocity.y -= 9.8 * 100.0 * delta; // 100.0 = mass;
        console.log("initial: " + position_x + "," + position_z);


        direction.z = Number(moveForward) - Number(moveBackward);
        direction.x = Number(moveRight) - Number(moveLeft);
        direction.normalize(); // this ensures consistent movements in all directions
        if (moveForward || moveBackward) velocity.z -= direction.z * 20.0 * delta;
        //	          if ( moveForward || moveBackward ) velocity.z -= direction.z * delta;
        if (moveLeft || moveRight) velocity.x -= direction.x * 20.0 * delta;
        //	          if ( moveLeft || moveRight ) velocity.x -= direction.x * delta;
        if (moveUp || moveDown) velocity.y -= direction.y * 20.0 * delta;
        if (onObject === true) {
            velocity.y = Math.max(0, velocity.y);
            canJump = true;
        }

        if (camera.position.x >= -10.17 && camera.position.x <= 7 && camera.position.z >= -8.39 && camera.position.z <= 3.09 && camera.position.y >= -2 && camera.position.y <= 8) {
            controls.moveRight(-velocity.x * delta);
            controls.moveForward(-velocity.z * delta);
            /*controls.moveUp( -velocity.y * delta );*/

            controls.getObject().position.y += (velocity.y * delta); // new behavior
            if (controls.getObject().position.y < -2) {
                velocity.y = -2;
                controls.getObject().position.y = -2;
            }
        }
        else {
            console.log("first: " + position_x + "," + position_z);
            if (camera.position.x < -10.17) { position_x = -10.07; }
            if (camera.position.x > 5.7) {
                position_x = 5.6;
            }
            if (camera.position.z > 1.7) {
                position_z = 1.6;
            }
            if (camera.position.z < -8.39) {
                position_z = -8.29;
            }
            if (camera.position.y < -2) { camera.position.y = -2; }
            if (camera.position.y > 8) { camera.position.y = 8; }

            console.log("second: " + position_x + "," + position_z);
            camera.position.set(position_x, -2, position_z);
            /*camera.position.set(position_x, position_y, position_z);*/
        }

        prevTime = time;
        //console.log (camera.position.x + ", " + camera.position.z);
        //console.log (position_x + ", " + position_z);
    }
    renderer.render(scene, camera);
}
