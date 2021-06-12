extends Node2D
export  (Array,PackedScene) var Prefabs
var floatblocks:Array;
var innerTime=0.0;
var paused=false;
var currentPrefab;
export var block:PackedScene;
var blocks:Array
var totalCount=0;
var starty=0;
var totalRow=0;
var GameLosed=false;
export var bb:PackedScene;
var score=0;
var partSize=64
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func Init():
	#$Label.z=9999
	#$Label.z_index=1;
	$"d-pad".z_index=1;
	var z=get_viewport_rect().size 
	$"d-pad".position=Vector2(z.x*0.2,z.y-250)
	$"d-pad/up".global_position.x = z.x- partSize*6;
	$"d-pad/down".global_position.x = z.x- partSize*6;
	 
	
	$"d-pad".scale=Vector2(partSize/32,partSize/32)
	partSize=z.x/10;
	$CreatePoint.position=Vector2(z.x/2,0)
	$Polygon2D.scale=Vector2(100,100)
	var i=0;
	while(i<z.y+partSize):
		totalRow+=1
		var t=block.instance()
		t.position=Vector2(0,i)
		t.scale=Vector2(partSize/32,partSize/32)
		add_child(t)
		t=block.instance()
		t.position=Vector2(z.x,i)
		t.scale=Vector2(partSize/32,partSize/32)
		add_child(t)
		i+=partSize;
	totalRow-=2
	var ty=i-partSize
	i=0
	starty=ty-partSize-partSize
	while(i<z.x):
		var t=block.instance()
		t.position=Vector2(i,ty-partSize)
		t.scale=Vector2(partSize/32,partSize/32)
		add_child(t)
		i+=partSize
		totalCount+=1
	totalCount-=2
func createPrefab():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var i= (rng.randi_range(1,Prefabs.size()-1)) 
	currentPrefab=Prefabs[i].instance();
	add_child(currentPrefab)
	
	currentPrefab.position=$CreatePoint.position
	currentPrefab.scale=Vector2(partSize/32,partSize/32)
	floatblocks=currentPrefab.get_children()
	for xx in floatblocks:
		xx.scale=Vector2(0.25,0.25)
	print(floatblocks.size())

# Called when the node enters the scene tree for the first time.
func _ready():
	Init()
	createPrefab();

func checkFree(vec:Vector2):
	
	var sp=get_world_2d().direct_space_state;
	for  z in range(0,floatblocks.size()):
		var k=sp.intersect_ray(floatblocks[ z].global_position,floatblocks[z].global_position+vec ,floatblocks);
		print(floatblocks[ z].global_position)
		if k.size()>0:
			return false;
		
	return true
	

func convertBlock():
		for  z in range(0,floatblocks.size()):
			var t=block.instance()
			blocks.append(t)
			t.position =floatblocks[z].global_position
			#t.r= (starty- t.position.y)/partSize
			t.scale= Vector2(partSize/32,partSize/32)
			add_child(t)
		remove_child(currentPrefab)
		

var mtime=0;
func _physics_process(delta):
	if(Input.is_action_pressed("ui_accept")):
		paused=!paused;
	if(Input.is_action_pressed("ui_select")):
		get_tree().reload_current_scene()
	if(paused):
		return;
	
	if(GameLosed==true):
		return
	
	mtime+=delta;
	if(mtime>0.2):
		if(Input.is_action_pressed("ui_left")):
			if(checkFree(Vector2(-partSize,0))):
				currentPrefab.position+=Vector2(-partSize,0)
		if(Input.is_action_pressed("ui_right")):
			if(checkFree(Vector2(partSize,0))):
				currentPrefab.position+=Vector2(partSize,0)
		if(Input.is_action_pressed("ui_up")):
			currentPrefab.rotation_degrees+=90
			if(checkFree(Vector2(1,0))==false):
				 currentPrefab.rotation_degrees-=90
		mtime=0
	innerTime+=delta
	if(Input.is_action_pressed("ui_down")):
		innerTime+=delta*3
	if(innerTime>0.5):
		innerTime=0;
		if(checkFree(Vector2(0,partSize))):
			currentPrefab.position.y+=partSize;
		else:
			convertBlock()
			clearfilledRow()
			createPrefab()
			if(checkFree(Vector2(0,1))==false):
				GameLosed=true;
				$Label.text+=" You Losed!"
			
func clearfilledRow():
	var counter=Array();
	for z in range(0,totalRow+5):
		counter.append(0)
	for z in blocks:
		counter[ ( starty- z.position.y )/partSize ]+=1
	var p=0;
	for z in range(totalRow,0-1,-1):
		if(counter[z]==totalCount+1):
			p+=1;
			for z3 in range(blocks.size()-1,-1,-1):
				var z2=blocks[z3]
				if(z2.position.y==(starty-(z*partSize) )):
					 
					blocks.remove(z3)
					remove_child(z2)
				
	for z in range(totalRow,0-1,-1):
		if(counter[z]==totalCount+1):
			for z3 in range(blocks.size()-1,-1,-1):
				var z2=blocks[z3]
				if(z2.position.y<(starty-(z*partSize) )):
					 z2.position.y+=partSize
	p=p*p;
	score+=p*100;
	$Label.text="Score:" + str(score)

	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
