#!/usr/bin/python3

import os
import yaml
import shutil

def get_project_name(info='./info.yaml'):
	with open(info) as f:
		dict = yaml.load(f, Loader=yaml.FullLoader)
		return dict['caravel_test']['module_name']

def get_latest_run(path='./runs'):
	dir_list = []
	with os.scandir(path) as it:
		for entry in it:
			if not entry.name.startswith('.') and entry.is_dir():
				dir_list += [(entry.path,os.stat(entry.path).st_ctime)]
	if len(dir_list) == 0:
		print('Directory empty!!!')
		quit()
	dir_list.sort(reverse=True,key=lambda a: a[1])
	return dir_list[0][0]
	
PROJECT_NAME = get_project_name()
RUN_DIR = get_latest_run()

copy_list = []
copy_list += [(RUN_DIR+os.sep+'results'+os.sep+'magic'+os.sep+PROJECT_NAME+'.gds','./gds')]
copy_list += [(RUN_DIR+os.sep+'results'+os.sep+'magic'+os.sep+PROJECT_NAME+'.gds.png','./docs')]
copy_list += [(RUN_DIR+os.sep+'results'+os.sep+'magic'+os.sep+PROJECT_NAME+'.lef','./gds')]
copy_list += [(RUN_DIR+os.sep+'results'+os.sep+'lvs'+os.sep+PROJECT_NAME+'.lvs.powered.v','./gds')]

for i in copy_list:
	shutil.copy(i[0],i[1])
	print(i[0],'>>',i[1])




