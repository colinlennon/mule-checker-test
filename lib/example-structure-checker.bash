#! /bin/bash
echo -e "---Starting MuleSoft Application Checks---\n"

echo -e "---Application Path: $PWD---\n"

#START VARS INIT

#Var to keep a list of the folders which are missing
missingFolders=""
#Pattern for checking file naming of files in implementation folder
implementationPattern="^.*\/(post-|get-|put-|patch-|delete-|subscriber-|publisher-|scheduler-|batch-|authorisation)+.*\.xml$"
#Pattern for checking file naming of files in the certificates folder
#certificatePattern="^.*\/.*(-keystore\.|-truststore\.).*$"
certificatePattern="^.*\/(keystore_|truststore_)+.*\.jks$"
#Pattern for finding certificate files
certificateFileFinder="^.*\/.*.(jks|pkcs12|pem|crt|pub|jceks|JKS|PKCS12|PEM|CRT|PUB|JCEKS)$"
#Pattern for checking file names follow lower-kebab-case naming
lowerKebabCase="[.a-z\d\/-]"
#Used to identify if a file path contains /certificates/
certificatesFolder="^.*\/cert\/.*$"
#Pattern for checking file naming of files in the examples folder
examplePattern="^.*\/.*(-input\.|-output\.|-request\.|-response\.).*$"
#Var to contain all bad file names
badFileNames=""
#Var to contain all files in the wrong directory
filesInWrongPlace=""
#Var to keep track of all files which are missing
missingFiles=""

#END VARS INIT

#CHECK 1/2

#START CHECK FOR FOLDERS WHICH MUST BE PRESENT IN EVERY APPLICATION

echo -e "---Starting Folder Structure Checks---\n"

if [ ! -d "src" ]; 
then
  echo "FAILURE: src directory does not exist."
  missingFolders="src"
else
  echo "SUCCESS: src directory found."
fi

if [ ! -d "src/main" ]; 
then
  echo "FAILURE: src/main/ directory does not exist."
  missingFolders="$missingFolders,src/main"
else
  echo "SUCCESS: src/main/ directory found."
fi

if [ ! -d "src/main/mule" ]; 
then
  echo "FAILURE: src/main/mule directory does not exist."
  missingFolders="$missingFolders,src/main/mule"
else
  echo "SUCCESS: src/main/mule directory found."
fi

if [ ! -d "src/main/mule/common" ]; 
then
  echo "FAILURE: src/main/mule/common directory does not exist."
  missingFolders="$missingFolders,src/main/mule/common"
else
  echo "SUCCESS: src/main/mule/common directory found."
fi

if [ ! -d "src/main/mule/implementation" ]; 
then
  echo "FAILURE: src/main/mule/implementation directory does not exist."
  missingFolders="$missingFolders,src/main/mule/implementation"
else
  echo "SUCCESS: src/main/mule/implementation found."
fi

if [ ! -d "src/main/resources" ]; 
then
  echo "FAILURE: src/main/resources directory does not exist."
  missingFolders="$missingFolders,src/main/resources"
else
  echo "SUCCESS: src/main/resources directory found."
fi

if [ ! -d "src/main/resources/dwl" ]; 
then
  echo "FAILURE: src/main/resources/dwl directory does not exist."
  missingFolders="$missingFolders,src/main/resources/dwl"
else
  echo "SUCCESS: src/main/resources/dwl directory found."
fi

if [ ! -d "src/main/resources/properties" ]; 
then
  echo "FAILURE: src/main/resources/properties directory does not exist."
  missingFolders="$missingFolders,src/main/resources/properties"
else
  echo "SUCCESS: src/main/resources/properties directory found."
fi

echo -e "\n---Finished Folder Structure Checks---\n"

#END CHECK FOR FOLDERS WHICH MUST BE PRESENT IN EVERY APPLICATION

#CHECK 2/2

echo -e "---Starting File Checks---\n"

#START CHECK FOR FILES WHICH SHOULD BE IN EVERY APPLICATION

if [ -f "src/main/mule/common/global.xml" ]
then
   echo -e "SUCCESS: src/main/mule/common/global.xml found"
else
   echo -e "FAILURE: src/main/mule/common/global.xml not found"
   missingFiles="src/main/mule/common/global.xml"
fi

#if [ -f "src/main/mule/common/global-secured-config.xml" ]
#then
#   echo -e "SUCCESS: src/main/mule/common/global-secured-config.xml found"
#else
#   echo -e "FAILURE: src/main/mule/common/global-secured-config.xml not found"
#   missingFiles="$missingFiles,src/main/mule/common/global-secured-config.xml"
#fi

#END CHECK FOR FILES WHICH SHOULD BE IN EVERY APPLICATION


#START CHECK FOR ANY FILE NOT LOWER KEBAB CASE

if [ ! -d "src/main" ]; 
then
  echo "src/main directory does not exist."
else
  #IF FOLDER EXISTS, ENSURE NAMING CONVENTION IS FOLLOWED
  for FILE in src/main/* src/main/*/**/***;
  do
	#echo -e "Checking lower-kebab-case Naming Standard for File: $FILE";
	if [[ ! $FILE =~ $lowerKebabCase ]]
	then
        echo -e "FAILURE: $FILE does not match the naming standard\n"
        badFileNames="$badFileNames,$FILE"
    fi
  done
fi

#END CHECK FOR ANY FILE NOT LOWER KEBAB CASE

#START CHECK FOR THE PRESENCE OF ANY CERTIFICATES OUTSIDE OF THE CERTIFICATES FOLDER

for FILE in src/main/resources/* src/main/resources/**/*;
  do
  	#CHECK THAT THE FILE IS NOT ALREADY IN THE CERTIFICATES FOLDER
  	if [[ ! $FILE =~ $certificatesFolder ]]
    then
     #IF IT ISNT IN THE CERTIFICATES FOLDER - CHECK IT IS NOT A CERTIFICATE IN THE WRONG PLACE
     #echo -e "Checking if File: $FILE is a certificate\n";
	 if [[ $FILE =~ $certificateFileFinder ]]
	 then
		echo -e "FAILURE: $FILE should be in the certificates folder\n"
		filesInWrongPlace="$filesInWrongPlace,$FILE"
     fi
  	fi
	
  done

#END CHECK FOR THE PRESENCE OF ANY CERTIFICATES OUTSIDE OF THE CERTIFICATES FOLDER

#START CHECKING THE FILENAMES OF CERTIFICATE FILES

#CHECK IF CERTIFICATES FOLDER EXISTS - IT IS NOT MANDATORY

if [ -d "src/main/resources/cert" ]; 
then
  #IF CERTIFICATES FOLDER EXISTS, ENSURE NAMING CONVENTION IS FOLLOWED
  #echo "src/main/resources/cert directory found."
  for FILE in src/main/resources/cert/*;

  do
	#echo -e "Checking Naming Standard for Certificate File: $FILE\n";
	if [[ $FILE =~ $certificatePattern ]]
	then
		echo -e "SUCCESS: $FILE matches naming standard"
	else
        echo -e "FAILURE: $FILE does not match the naming standard"
        badFileNames="$badFileNames,$FILE"
    fi
  done
fi
#END CHECKING THE FILENAMES OF CERTIFICATE FILES

#START CHECKING THE FILENAMES OF EXAMPLE FILES

#CHECK IF EXAMPLES FOLDER EXISTS - IT IS NOT MANDATORY

if [ -d "src/main/resources/examples" ]; 
then
  #IF EXAMPLES FOLDER EXISTS, ENSURE NAMING CONVENTION IS FOLLOWED
  #echo "src/main/resources/certificates directory found."
  for FILE in src/main/resources/examples/*;

  do
	#echo -e "Checking Naming Standard for Example File: $FILE\n";
	if [[ $FILE =~ $examplePattern ]]
	then
		echo -e "SUCCESS: $FILE matches naming standard"
	else
        echo -e "FAILURE: $FILE does not match the naming standard"
        badFileNames="$badFileNames,$FILE"
    fi
  done
fi
#END CHECKING THE FILENAMES OF EXAMPLE FILES

#START CHECKING THE FILENAMES OF IMPLEMENTATION FILES

#for FILE in src/main/mule/implementation/*;
#
#do
#	#echo -e "Checking Naming Standard for Implementation File: $FILE\n";
#	if [[ $FILE =~ $implementationPattern ]]
#	then
#		echo -e "SUCCESS: $FILE matches naming standard"
#	else
#        echo -e "FAILURE: $FILE does not match the naming standard"
#        badFileNames="$badFileNames,$FILE"
#    fi
#done

#END CHECKING THE FILENAMES OF IMPLEMENTATION FILES

echo -e "\n---Finished File Checks---\n"
echo -e "---Finished All Checks---\n"
echo -e "---Folders Missing---"
echo -e "${missingFolders:1}"
echo -e "---Files Missing---"
echo -e "$missingFiles"
echo -e "---Files Incorrectly Named---"
echo -e "${badFileNames:1}"
echo -e "---Files in the Incorrect Directory---"
echo -e "${filesInWrongPlace:1}"



if ([ -z $missingFolders ] && [ -z $missingFiles ] && [ -z $badFileNames ] && [ -z $filesInWrongPlace ]);
then
 echo -e "---Result: PASSED---"
 echo -e "---Finished MuleSoft Application Checks---\n"
else
 echo -e "\n---Result: FAILED---"
 echo -e "---Finished MuleSoft Application Checks---\n"
 exit 1;
fi
