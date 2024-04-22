.entity player_model;
.float melee_lunge;

/*
So I don't think I understand framegroups properly but I tried to get something working quick and dirty.
In the end I think I spent more time than necessary but that's half the fun. I also may have misunderstood the original intention on 
how this was supposed to be implemented but tried to build off what was there as much as my mere mortal brain would allow,
so hopefully someone (from the original team or otherwise) can step in and maybe tidy things up? 
I'd be really really greatful to learn more from this. Please and thank you with cinnamon and cherries on top!

See block comment path of destruction below!

Anyway, hopefully things get a little less janky with every submission/PR/drop. Woohoo!

-MrC
*/

/*
Brought in from Q1.5, there might be similar functions elsewhere in this codebase but I didn't really look. 
Also thanks once again for the treasure trove that is Quake 1.5! 
*/

var float autocvar_debug_frames = 0;

float (vector from, vector to) Dot =
{
	return from_x * to_x + from_y * to_y + from_z * to_z;
};

float(entity ent) checkUPS_forward =
{
	makevectors(ent.angles);
	local float DotComp = Dot(v_forward, ent.velocity);
	return DotComp;
}

float(entity ent) checkUPS_right =
{
	makevectors(ent.angles);
	local float DotComp = Dot(v_right, ent.velocity);
	return DotComp;
}

float(vector tor_ang) defineLmax =
{
	local float lmax;
	lmax = tor_ang_y + 90;
	
	if (lmax > 360)
		lmax-=360;
	else if (lmax <= 0)
		lmax+=360;
		
	if (tor_ang_y >=270 && tor_ang_y <= 360)
		lmax+=360;
		
	return lmax;
}

float(vector tor_ang) defineRmax =
{
	local float rmax;
	rmax = tor_ang_y - 90;
	
	if (rmax >= 360)
		rmax-=360;
	else if (rmax <= 0)
		rmax+=360;
		
	if (tor_ang_y <=90 && tor_ang_y >= 0)
		rmax-=360;
		
	return rmax;
}


void() DebugAngles =
{
	local vector plrang;
	local float lmax, rmax;
	
	
	if (self.owner.angles_y >= 0)
		plrang_y = self.owner.angles_y;
	else
		plrang_y = self.owner.angles_y + 360;
		
	lmax = defineLmax(plrang);
	rmax = defineRmax(plrang);	
	
	if (autocvar_debug_frames)
		centerprint(self.owner, strcat("player frame: ", ftos(self.owner.frame), " dummy leg frame: ", ftos(self.frame), "\n V_Right: ", ftos(checkUPS_right(self.owner)), "\n V_Forward: ", ftos(checkUPS_forward(self.owner))), strcat("\n legs angles: ", vtos(self.angles), "\n parent angles: ", vtos(plrang), "\n parent v_angle: ", vtos(self.owner.v_angle), "\n Legs left max: ", ftos(lmax)), strcat(" \n Legs right max: ", ftos(rmax)));
			
}

void() weapon_think =
{
	if(self.owner.weapon != self.weapon)
	{
		self.colormod = self.owner.vweapon.colormod;
		if(self.owner.weapon == IT_MELEE)
			setmodel(self, "models/weapons/melee/v_blade.md3");
		if(self.owner.weapon == IT_REVOLVER)
			setmodel(self, "models/weapons/revolver/w_revolver.md3");
		if(self.owner.weapon == IT_SHOTGUN)
			setmodel(self, "models/weapons/shotgun/w_shotgun.md3");
		if(self.owner.weapon == IT_SPITTER)
			setmodel(self, "models/weapons/spitter/w_spitter.md3");
		if(self.owner.weapon == IT_RETCHER)
			setmodel(self, "models/weapons/retcher/w_retcher.md3");
		if(self.owner.weapon == IT_CANNON)
			setmodel(self, "models/weapons/cannon/w_cannon.md3");
		if(self.owner.weapon == IT_LANCE)
			setmodel(self, "models/weapons/lance/w_lance.md3");
		if(self.owner.weapon == IT_CRYSTAL)
			setmodel(self, "models/weapons/crystal/w_crystal.md3");
		if(self.owner.weapon == IT_MACE)
			setmodel(self, "models/weapons/mace/w_mace.md3");		

		self.weapon = self.owner.weapon;
	}
	self.think = weapon_think;
	self.nextthink = time + 0.05;
};

/*
// first frame, num frames, frames per second, loop flag
0	266	20	1	//0 ALL
0	0	0	0	//1 LEGS_TPOSE
93	0	0	1	//2 LEGS_STAND_IDLE
1	13	25	1	//3 LEGS_RUN_FORWARD
15	13	25	1	//4 LEGS_RUN_BACK
29	13	25	1	//5 LEGS_RUN_LEFT
43	13	25	1	//6 LEGS_RUN_RIGHT
56 	18	20	0	//7 LEGS_STAND_TO_CROUCH
74	1	0	0	//8 LEGS_CROUCH_IDLE
75	18	20	0	//9 LEGS_CROUCH_TO_STAND
94	24	20	1	//10 LEGS_CROUCH_FORWARD
119 27	20	1	//11 LEGS_CROUCH_BACK
147 25	20	1	//12 LEGS_CROUCH_LEFT
173 22	20	1	//13 LEGS_CROUCH_RIGHT
203	5	20	0	//14 LEGS_JUMP_START
207	1	0	1	//15 LEGS_JUMP_LOOP
212	13	20	0	//16 LEGS_JUMP_LAND
226	21	20	1	//17 LEGS_DASH_LOOP
248	18	20	0	//18 LEGS_DASH_LAND
94	0	0	0	//19 NEW LEGS_CROUCH_IDLE
*/

.float onground_time;
void() lower_think =
{
	if((self.owner.vhud != 3) &&(self.exteriormodeltoclient != self.owner))
		{self.exteriormodeltoclient = self.owner;self.effects = 0;}
	if((self.owner.vhud == 3)&&(self.exteriormodeltoclient == self.owner))
		{self.exteriormodeltoclient = world; self.effects = EF_NODRAW;}

	//local string lmessage;
	//lmessage =strcat ((vtos(self.owner.angles)),("\n")) ;
	//bprint (lmessage);
	//setorigin (self, self.owner.origin);
//	if((self.owner.wrathflags & FL_WONGROUND))
	if(self.owner.onground_time > time)
	{
		float speed = vlen (self.owner.velocity);
	//	float ownerForward = checkUPS_forward(self.owner);
	//	centerprint(self.owner, ftos(ownerForward));
		
		if (speed > 30)
		{
			if(self.owner.crouch)
			{
			//	self.frame = 10;
				
				if (checkUPS_forward(self.owner) > 100)
				{
					self.frame = 10; //CROUCH FORWARD FRAMEGROUP

				}
				else if (checkUPS_forward(self.owner) < -100)
				{
					self.frame = 11; //CROUCH BACK FRAMEGROUP

				}
				else if (checkUPS_right(self.owner) > 100)
				{
					self.frame = 13; //CROUCH RIGHT

				}
				else if (checkUPS_right(self.owner) < 100)
				{
					self.frame = 12; //CROUCH LEFT
				}
			}
			else
			{	
				if (checkUPS_forward(self.owner) > 300)
				{
					self.frame = 3; //RUN FORWARD FRAMEGROUP

				}
				else if (checkUPS_forward(self.owner) < -300)
				{
					self.frame = 4; //RUN BACK FRAMEGROUP

				}
				else if (checkUPS_right(self.owner) > 300)
				{
					self.frame = 6;

				}
				else if (checkUPS_right(self.owner) < 300)
				{
					self.frame = 5;
				}
			}
		}
		else
		{
		if(self.owner.crouch)
		{	
			self.frame = 19;
		}
			
		else	
			self.frame = 1;
		}
	}
	else
	{
		if (self.owner.melee_lunge == 1)
		{
			self.frame = 17;
		}
		else if (self.owner.waterlevel >= 2)
		{
			if (checkUPS_forward(self.owner) > 20)
			{
				self.frame = 3; //RUN FORWARD FRAMEGROUP (REPLACE WITH SWIM FORWARD)
			}
			else if (checkUPS_forward(self.owner) < -20)
			{
				self.frame = 4; //RUN BACK FRAMEGROUP
			}
			else if (checkUPS_right(self.owner) > 20)
			{
				self.frame = 6;
			}
			else if (checkUPS_right(self.owner) < 20)
			{
				self.frame = 5;
			}		
		}
		else
		{
			self.frame = 15;	
		}
	}

	//self.v_angle_x = self.owner.angles_x;
	self.angles_x = -self.owner.angles_x * 0.666666666666666666666666;

	//vector selfangles= vectoangles(self.owner.velocity);
	self.angles_z = 0;
	self.angles_y = 0;

	DebugAngles();	
	
	self.think = lower_think;
	self.nextthink = time + 0.01;
};
.entity torso_model;
.float torso_time;
/*
If you add a framegroup to outlander_new_upper.MD3.framegroups, change the following block comment.

//UNTESTED 
// first frame, num frames, frames per second, loop flag
0	115	15	1 	//0 ALL
0	0	0	0	//1 UPPER_TPOSE
1	1	0	0	//2 UPPER_RIFLE (two handed)
2	15	20	0	//3 UPPER_DASH_START
18	21	20	1	//4 UPPER_DASH_LOOP
40	20	25	0	//5 UPPER_MELEE_ATTACK
61	1	0	0	//6 UPPER_MELEE_IDLE
62	7	20	0	//7 UPPER_DASH_FIRE
70 	18	20	0	//8 UPPER_WEAPON_SWITCH
1	1	0	0	//9 UPPER_PISTOL_IDLE
89 	5	10	0	//10 UPPER_PISTOL_ATTACK
89	5	10	0	//11 UPPER_RIFLE_ATTACK
95	20 	15	0	//12 UPPER_RIFLE_RELOAD
89 	5	20	1	//13 UPPER_PISTOL_ATTACK_LOOP
*/
void() torso_think =
{
	self.angles_x = self.owner.angles_x * 2;
	self.angles_z = 0;
	self.angles_y = 0;
	self.think = torso_think;
	//self.nextthink = time + 0.025;
	self.nextthink = time + 0.025;
	
	if (self.torso_time > time)
		return;
	
	/*
	if (self.owner.realoding == 1 && self.frame != 12)
	{
		self.frame = 12;
		self.torso_time = time + 1.33;
	//	self.torso_time = time + frameduration(self.modelindex, 12);
		return;
	}
	*/
	
	if((self.owner.button0)||(self.owner.button3))
//	if (self.owner.attack_finished > time)
	{
		if(self.owner.button0)
		{
				//if((self.owner.weapon == IT_MELEE || self.owner.weapon == IT_MACE) && (self.frame != 5))
				if(self.owner.weapon == IT_MELEE || self.owner.weapon == IT_MACE)
				{
					self.frame = 5;
				//	self.torso_time = time + frameduration(self.modelindex, 5);
				//	self.torso_time = time + 0.7;
				//	return;					
				}
				else if ((self.owner.weapon == IT_SHOTGUN) && (self.frame != 12))
				{
					self.frame = 12;
					//self.torso_time = time + 1.33;
					self.torso_time = time + frameduration(self.modelindex, 12);
					return;		
				}
				/*				
				else if ((self.owner.weapon == IT_SHOTGUN) && (self.frame != 12))
				{
					self.frame = 12;
					self.torso_time = time + frameduration(self.modelindex, 12);
					return;		
				}
				*/
				
				else if (self.owner.weapon == IT_CRYSTAL) //attempt to fix weird frame stuff
				{
					self.frame = 13;	
				}				
				else
				{
					self.frame = 10; //PISTOL (UPPER RIFLE SHOOT FOR NOW)
					self.torso_time = time + frameduration(self.modelindex, 10);
					return;	
				}
		}
		else
		{
			if(self.owner.weapon == IT_MELEE)
				self.frame = 3;

			if(self.owner.weapon == IT_MACE)
				self.frame = 7;				
			
			if(self.owner.weapon == IT_SHOTGUN)
				self.frame = 10;	
		}
	}
	else
	{
		if(self.owner.onground_time > time)
		{
			if(self.owner.weapon == IT_MELEE || self.owner.weapon == IT_MACE)
				self.frame = 6; //6
			else
				self.frame = 2;
		}
		else 
		{
			if(self.owner.weapon == IT_MELEE){
				self.frame = 4; //4
			}
		}		

		if(self.owner.weapon == IT_MELEE)
			self.frame = 7;
	}
};
void(entity e) spawn_player_models =
{
	entity playermodel, torso;
	
	playermodel = spawn();
	e.player_model = playermodel; 
	/*playermodel.origin = e.origin;
	playermodel.movetype = MOVETYPE_FOLLOW;
	playermodel.aiment = e;*/
	playermodel.owner = e;
	playermodel.wrathflags = FL_GARBAGE;
	setattachment(playermodel, e,"");
	playermodel.frame = 0;
	playermodel.exteriormodeltoclient = e;
	setmodel(playermodel, "models/player/outlander/outlander_new_lower.MD3");
	//playermodel.origin += '0 0 5';
	//playermodel.angles = '0 90 0';
	
	//playermodel.origin += '0 0 5.5'; //model was in the floor, nudge it up a bit.
	playermodel.scale = 1.0;
	playermodel.think = lower_think;
	playermodel.nextthink = time + 0.05;

	torso = spawn();
	torso.owner = e;
	e.torso_model = torso;
	//setmodel(torso, "models/player/outlander/outlander_upper_baked.MD3");
	//setmodel(torso, "models/player/outlander/outlander_new_upper.MD3");
	setmodel(torso, "models/player/outlander/outlander_new_upper.MD3");
	//void(entity e, entity tagentity, string tagname) setattachment
	setattachment(torso,playermodel, "tag_mid");
	torso.frame = 0;
	torso.wrathflags = FL_GARBAGE;
	torso.think = torso_think;
	torso.nextthink = time + 0.05;
	torso.scale = 1.0;

	entity weapon = spawn();
	weapon.wrathflags = FL_GARBAGE;
	weapon.owner = e;
	setmodel(weapon, "models/weapons/shotgun/w_shotgun.md3");
	setattachment(weapon,torso, "tag_weapon");
	weapon.scale = 0.5;
	weapon.think = weapon_think;
	weapon.nextthink = time + 0.05;	
	
	/*
	entity head = spawn();
	head.owner = e;
	setmodel(head, "models/player/outlander/head.md3");
	setattachment(head,torso, "tag_head");
	head.wrathflags = FL_GARBAGE;
	head.think = torso_think;
	head.nextthink = time + 0.05;
	*/	
};

void(entity e) spawn_player_model =
{
setmodel(e,"models/player/outlander/outlander_full_tpose.MD3");
}
void()corpse_dead_think =
{
self.think = SUB_Remove;
self.nextthink = time + 30;
}

void(vector org, vector ang)spawn_dead_model =
{
	entity fakeplayer = spawn();
	setmodel(fakeplayer, "models/misc/null.md3");
	fakeplayer.origin = org;
	fakeplayer.angles_y =ang_y;
	float r = random();
	if (r < 1)
	fakeplayer.frame = 0;
	if (r < 0.65)
	fakeplayer.frame = 2;
	if (r < 0.35)
	fakeplayer.frame = 4;


	entity playermodel, torso;
	playermodel = spawn();
	playermodel.owner = fakeplayer;
	playermodel.wrathflags = EF_LOWPRECISION;
	setattachment(playermodel, fakeplayer,"");
	setmodel(playermodel, "models/player/outlander/lower.md3");
	playermodel.think = corpse_dead_think;
	playermodel.nextthink = time + 1.55;
	playermodel.frame = fakeplayer.frame;
	torso = spawn();
	torso.owner = fakeplayer;
	setmodel(torso, "models/player/outlander/upper.md3");
	setattachment(torso,playermodel, "tag_torso");
	torso.frame = fakeplayer.frame;
	torso.think = corpse_dead_think;
	torso.nextthink = time + 1.55;
	entity head = spawn();
	head.owner = fakeplayer;
	setmodel(head, "models/player/outlander/head.md3");
	setattachment(head,torso, "tag_head");
	head.think = corpse_dead_think;
	head.nextthink = time + 1.55;
};
