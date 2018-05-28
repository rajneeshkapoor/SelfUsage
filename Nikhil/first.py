import subprocess
import commands 
from subprocess import call
from termcolor import colored, cprint
'''
call('pwd')
print(colored("this is not right now",'blue'))

'''

#Main Menu

def show_menu():
	print(colored("\nSelect the operation : ",'white'))
	print(colored("\n1. Openstack and TriliVault version",'magenta'))
	print(colored("2. CRUD",'cyan'))
	#print(colored("4. CRUD on Workload",'green'))
	#print(colored("5. Snapshot of Instance",'yellow'))
	#print(colored("6. Backup and Restore of workloads",'red'))
	print(colored("7. Exit\n",'white'))
#1

def opnstck_trlo_version():
	print("\n")	
	call('openstack --version', shell=True)
	#call('workloadmgr --version',shell=True)
	#op = subprocess.check_output('workloadmgr --version',shell=True)
	#print("Triliovault - ", op)
	#print("Trivliovault - "+subprocess.check_output('workloadmgr --version',shell=True))
	ad = commands.getstatusoutput('workloadmgr --version')
	print("TrilioVault - "+ad[1])

##2

def show_crud_menu():
	print("\nOperation :  ")
	print("1.Create\n2.Retrieve\n3.Update\n4.Delete\n5.Exit\n")

def on_what_show():
	print("\nfor???")
	print("1.Images\n2.Volumes\n3.Instances\n4.Workloads\n5.Exit\n")


####2.1 



def call_particular_create():
	
	 d=0
        while(d!=5):
                on_what_show()
                d=int(input())
                if(d==1):
                        img_create()
                elif(d==2):
                        vol_create()
                elif(d==3):
                        inst_create()
                elif(d==4):
			workload_create()


####2.2

def img_list():
        print("\n")
        call('openstack image list', shell=True)

def vol_list():
        print("\n")
        call('openstack volume list', shell=True)

def inst_list():
        print("\n")
        call('nova list', shell=True)

def wrkld_list():
        print("\n")
        call('workloadmgr workload-list', shell=True)


def call_particular_retrieve():
	c=0
	while(c!=5):
		on_what_show()
		c=int(input())
		if(c==1):
			img_list()
		elif(c==2):
			vol_list()
		elif(c==3):
			inst_list()
		elif(c==4):


####2 main function

def crud():
        b = 0
        while b!=5:
                show_crud_menu()
                b = int(input())

                if(b==1):
			call_particular_create()
                        pass
                elif(b==2):
			call_particular_retrieve()
                        pass
                elif(b==3):
                        pass
		elif(b==4):
			pass

############ Main Function

if __name__=="__main__":
	
	a = 0

	while a!= 7:
		show_menu()
		a = int(input())
		
		if(a==1):
			opnstck_trlo_version()
		elif(a==2):
			crud()




