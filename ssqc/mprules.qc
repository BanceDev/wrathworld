
// TODO: Look at how journal/weapon messages are sent
void DeathMessage() = {

};

// update player frags score
void PointsForKill() = {

};


/*
===============================================================================

PLAYER BACKPACKS

===============================================================================
*/

void() BackpackTouch =
{
	if !(other.flags & FL_CLIENT) // only clients
		return;
	if (other.classname != "player") // no spectators, if we have that kind of thing
		return;
	if (other.deadflag != DEAD_NO)
		return;
	
	// handle ammo transfer first
	other.ammo_revolver += self.ammo_revolver;
    other.ammo_shotgun += self.ammo_shotgun;
    other.ammo_cannon += self.ammo_cannon;
    other.ammo_retcher += self.ammo_retcher;
    other.ammo_crystal += self.ammo_crystal;
    other.ammo_lance += self.ammo_lance;
    other.ammo_spitter += self.ammo_spitter;

	// give active weapon
	if (self.netname = "Lance")
		other.items |= IT_LANCE;
	else if (self.netname = "Crystalizer")
		other.items |= IT_CRYSTAL;
	else if (self.netname = "Cannon")
		other.items |= IT_CANNON;
	else if (self.netname = "Retcher")
		other.items |= IT_RETCHER;
	else if (self.netname = "Spitter")
		other.items |= IT_SPITTER;
	else if (self.netname == "Shotgun")
		other.items |= IT_SHOTGUN;
	else if (self.netname == "Revolver")
		other.items |= IT_REVOLVER;

	//play sound
	sound (other, CHAN_ITEM, "items/ammo_shotgun.ogg", 1, ATTN_NORM);
	remove(self);
};


// create a quakeworld style backpack on death
void DropBackpack() = {
    local entity pack;

	if (!(self.ammo_revolver + self.ammo_shotgun + self.ammo_cannon + self.ammo_retcher + self.ammo_crystal + self.ammo_lance + self.ammo_spitter))
		return; // nothing in it

	pack = spawn();
	pack.origin = self.origin - '0 0 0';
	
	pack.items = self.weapon;
	pack.netname = "";
	if (pack.items == IT_MELEE)
		pack.netname = "Melee";
    if (pack.items == IT_REVOLVER)
        pack.netname = "Revolver";
	if (pack.items == IT_SHOTGUN)
		pack.netname = "Shotgun";
	if (pack.items == IT_SPITTER)
		pack.netname = "Spitter";
	if (pack.items == IT_RETCHER)
		pack.netname = "Retcher";
	if (pack.items == IT_CANNON)
		pack.netname = "Cannon";
	if (pack.items == IT_CRYSTAL)
		pack.netname = "Crystalizer";
	if (pack.items == IT_LANCE)
		pack.netname = "Lance";
		
    pack.ammo_revolver = self.ammo_revolver;
    pack.ammo_shotgun = self.ammo_shotgun;
    pack.ammo_cannon = self.ammo_cannon;
    pack.ammo_retcher = self.ammo_retcher;
    pack.ammo_crystal = self.ammo_crystal;
    pack.ammo_lance = self.ammo_lance;
    pack.ammo_spitter = self.ammo_spitter;

	pack.velocity_z = 300;
	pack.velocity_x = -100 + (random() * 200);
	pack.velocity_y = -100 + (random() * 200);
	
	pack.flags = FL_ITEM;
	pack.solid = SOLID_TRIGGER;
	pack.movetype = MOVETYPE_TOSS;
	setmodel (pack, "progs/backpack.mdl");
	setsize (pack, '-16 -16 0', '16 16 56');
	pack.touch = BackpackTouch;
	
	pack.nextthink = time + 120;    // remove after 2 minutes
	pack.think = SUB_Remove;
};