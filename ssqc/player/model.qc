.entity player_model;
.float melee_lunge;

//Brought in from Q1.5, there might be similar functions elsewhere but I didn't really look so, put that on the todo.

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

		self.weapon = self.owner.weapon;
	}
	self.think = weapon_think;
	self.nextthink = time + 0.05;
};

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
				self.frame = 10;
				
				if (self.frame == 10)
				{
				//	self.origin = self.origin + '0 0 20';
				}
				else
				{
					//self.origin = self.origin - '0 0 20';
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
			self.frame = 8;
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
void() torso_think =
{
	if((self.owner.button0)||(self.owner.button3))
	{
		if(self.owner.weapon == IT_MELEE && self.frame != 5){
			self.frame = 5;
		}
		else if(self.owner.weapon == IT_SHOTGUN && self.frame != 12){
			self.frame = 12;
		}
		else{
			self.frame = 11;
		}
	}
/* 	else
	{
		if(self.frame != 25)
			self.frame = 25;
	} */
	else
	{
		if(self.owner.onground_time > time)
		{
			if(self.owner.weapon == IT_MELEE)
				self.frame = 6;
			else
				self.frame = 2;
		}
		else 
		{
			if(self.owner.weapon == IT_MELEE){
				self.frame = 4;
			}
		}			
		
	//	if((self.owner.weapon == IT_MELEE) && (self.frame != 5))
		/*
		if((self.owner.attack_finished > time)){
			self.frame = 6;
		}
		else	
		{
			if ((self.frame != 11) || (self.frame != 12))
				self.frame = 2;
		}
		*/
	}

	if(self.owner.onground_time > time)
	{
		float speed = vlen (self.owner.velocity);
		if (speed > 30)
		{
		if(self.owner.crouch){
			self.frame = 10;
		}
		else{
			self.frame = 3; //RUN FRAMEGROUP
		}
		}
		else
		{
		if(self.owner.crouch)
			self.frame = 8;
		else	
			self.frame = 2;
		}
	}
	else
	{
			self.frame = 15;

	}
	
	/*
	if (self.frame == 1)
	{		
		self.angles_x = self.owner.angles_x * 1.1;
	}
	else
	{
		self.angles_x = self.owner.angles_x * 2;
	}
	*/
	
	self.angles_x = self.owner.angles_x * 2;
	self.angles_z = 0;
	self.angles_y = 0;
	self.think = torso_think;
	self.nextthink = time + 0.025;
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
