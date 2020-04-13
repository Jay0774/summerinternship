from python
# it will ckeck  for python image else pull from dockerhub
maintainer jayeshbudhwani1999@gmail.com,9079320380
# developer of docker image
run mkdir /mycode
# run  instruction can execute any linux command inside my docker image 
copy hello.py /mycode/hello.py
# it will copy code from local system to docker image
cmd python /mycode/hello.py
# so this will run this code as default parent proccess

