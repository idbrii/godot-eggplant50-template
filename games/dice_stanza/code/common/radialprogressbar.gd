tool
extends Control
# https://github.com/kameloov/Radial-progress-bar/blob/master/addons/radial_progress/RadialProgressBar.gd
# MIT License
# 
# Copyright (c) 2020 Kamel Mohammad
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


const max_value := 1.0;
export(float, 1, 100) var radius := 120.0
export(float, 0, 1) var progress := 0.0
export(float, 0, 1) var thickness := 0.5
export var bg_color : Color  = Color(0.5,.5,0.5,1);
export var bar_color :Color =  Color(0.2,.9,0.2,1);
var angle = 0.0 ; 
var tween = Tween.new();
func _ready():
	add_child(tween);
	pass # Replace with function body.

func set_progress(v):
	progress = v;
	update();

func set_radius_and_thickness(r,th):
	radius = r; 
	thickness = th;
	update();

func set_colors(bg,bar):
	bg_color = bg;
	bar_color = bar;
	update();

func _draw():
	draw_circle_arc(Vector2(0,0),radius,0,360,bg_color);
	angle = progress*360/max_value;
	draw_circle_arc(Vector2(0,0),radius,0,angle,bar_color);
	draw_circle_arc(Vector2(0,0),radius * thickness,0,360,bg_color);
	pass;
	
func _process(_delta):
	 update();

func animate(duration,reverse = false,initial_value = 0):
	if reverse:
		tween.interpolate_method(self,"set_progress",max_value,initial_value,duration,Tween.TRANS_LINEAR,Tween.EASE_IN);
	else:
		tween.interpolate_method(self,"set_progress",initial_value,max_value,duration,Tween.TRANS_LINEAR,Tween.EASE_IN);
	tween.start();

func draw_circle_arc(center, arc_radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])
	for i in range(nb_points + 1):
	    var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
	    points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * arc_radius)
	draw_polygon(points_arc, colors)
