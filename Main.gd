extends Node2D
export  (Array,PackedScene) var Prefabs
var floatblocks:Array;
var innerTime=0.0;
var currentPrefab;
export var block:PackedScene;
var blocks:Array
var totalCount=0;
var starty=0;
var totalRow=0;
var GameLosed=false;
export var bb:PackedScene;
var score=0;
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func Init():
	var z=get_viewport_rect().size 
	$CreatePoint.position=Vector2(z.x/4,0)
	var i=0;
	while(i<z.y+32):
		totalRow+=1
		var t=block.instance()
		t.position=Vector2(0,i)
		add_child(t)
		t=block.instance()
		t.position=Vector2(z.x/2,i)
		add_child(t)
		i+=32;
	totalRow-=2
	var ty=i-32
	i=0
	starty=ty-32
	while(i<z.x/2):
		var t=block.instance()
		t.position=Vector2(i,ty)
		add_child(t)
		i+=32
		totalCount+=1
	totalCount-=2
func createPrefab():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var i= (rng.randi_range(1,Prefabs.size()-1)) 
	currentPrefab=Prefabs[i].instance();
	add_child(currentPrefab)
	currentPrefab.position=$CreatePoint.position
	floatblocks=currentPrefab.get_children()
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
			t.r= (starty- t.position.y)/32
			add_child(t)
		remove_child(currentPrefab)

var mtime=0;
func _physics_process(delta):
	if(GameLosed==true):
		return
	
	mtime+=delta;
	if(mtime>0.2):
		if(Input.is_action_pressed("ui_left")):
			if(checkFree(Vector2(-32,0))):
				currentPrefab.position+=Vector2(-32,0)
		if(Input.is_action_pressed("ui_right")):
			if(checkFree(Vector2(32,0))):
				currentPrefab.position+=Vector2(32,0)
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
		if(checkFree(Vector2(0,32))):
			currentPrefab.position.y+=32;
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
		counter[ ( starty- z.position.y )/32 ]+=1
	var p=0;
	for z in range(totalRow,0-1,-1):
		if(counter[z]==totalCount+1):
			p+=1;
			for z3 in range(blocks.size()-1,-1,-1):
				var z2=blocks[z3]
				if(z2.position.y==(starty-(z*32) )):
					 
					blocks.remove(z3)
					remove_child(z2)
				
	for z in range(totalRow,0-1,-1):
		if(counter[z]==totalCount+1):
			for z3 in range(blocks.size()-1,-1,-1):
				var z2=blocks[z3]
				if(z2.position.y<(starty-(z*32) )):
					 z2.position.y+=32
	p=p*p;
	score+=p*100;
	$Label.text="Score:" + str(score)

	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
