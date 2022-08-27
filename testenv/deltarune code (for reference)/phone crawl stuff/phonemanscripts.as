// obj_sneo_phonehand_master
// CREATE
event_inherited()
destroyonhit = false
image_speed = 0
image_xscale = 2
image_yscale = 2
siner = 0
element = 6
xdist = 70
phonehand_top = instance_create((x - xdist), (y - 70), obj_sneo_phonehand)
phonehand_top.orientation = "top"
phonehand_top.boss = id
phonehand_top.target = obj_sneo_bulletcontroller.target
phonehand_bottom = instance_create((x - xdist), (y + 60), obj_sneo_phonehand)
phonehand_bottom.orientation = "bottom"
phonehand_bottom.boss = id
phonehand_bottom.target = obj_sneo_bulletcontroller.target
movedx = 0
hp = 200
difficulty = 0
difficulty = obj_spamton_neo_enemy.difficulty
btimer = 0
init = false
visibiliytimer = 0
image_alpha = 0
bluesiner = 0
image_blend = merge_color(0xE8A200, c_aqua, (0.25 + (sin((bluesiner / 3)) * 0.25)))

// STEP
siner++
bluesiner++
image_blend = merge_color(0xE8A200, c_aqua, (0.25 + (sin((bluesiner / 3)) * 0.25)))
if (x >= (camerax() + 480))
    x = (camerax() + 480)
if (grazed == true)
{
    grazetimer += 1
    if (grazetimer >= 3)
    {
        grazetimer = 0
        grazed = false
    }
}
if instance_exists(obj_heart)
{
    if (obj_heart.x > (obj_sneo_phonehand_master.x - 36))
        obj_heart.x = (obj_sneo_phonehand_master.x - 36)
}
if (init == false)
{
    if (difficulty == 2)
    {
        with (obj_sneo_phonehand)
            alt = 1
    }
    phonehand_top.target = target
    phonehand_bottom.target = target
    init = true
}
if (difficulty == 0)
    y = (ystart + (sin((siner / 8)) * 40))
if (difficulty == 1 || difficulty == 2)
    y = (ystart + (sin((siner / 10)) * 60))
if i_ex(phonehand_top)
{
    if (difficulty < 2)
        x = lerp(x, (phonehand_top.x + xdist), 0.2)
    else
        x -= 1
}
if (difficulty == 0 || difficulty == 1 || difficulty == 2)
{
    btimer++
    threshold = 20
    if (difficulty == 1)
        threshold = 15
    if (difficulty == 2)
        threshold = 30
    if (btimer >= threshold && image_alpha >= 1)
    {
        btimer = 0
        if (difficulty < 2)
            shot = instance_create(x, y, obj_sneo_mmx_spreadshot)
        else
            shot = instance_create(x, y, obj_basicbullet_sneo)
        shot.speed = 12
        shot.image_xscale = 3
        shot.image_yscale = 3
        if (difficulty < 2)
            shot.friction = 1
        else
            shot.speed = 10
        shot.alarm[0] = 25
        shot.direction = (180 + random_range(-5, 5))
        shot.depth = (depth - 1)
        shot.target = target
        sprite_index = spr_sneo_head_open
        alarm[0] = 10
    }
}

// COLLISION
hp--
if (x <= (camerax() + 480))
{
    friction = 0.5
    if (other.big == 1)
        hspeed += 8
    else
        hspeed += 4
    var rembig = other.big
    with (obj_sneo_phonehand)
    {
        friction = 0.5
        hspeed += 2
        if rembig
            hspeed += 4
    }
}
snd_play(snd_damage)
if (x >= (camerax() + 480))
    x = (camerax() + 480)
with (other)
    event_user(0)
	
// DRAW
visibiliytimer++
if (visibiliytimer < 2)
    return;
if (image_alpha < 1)
    image_alpha += 0.1
draw_set_alpha(image_alpha)
draw_self()
draw_set_alpha(1)

