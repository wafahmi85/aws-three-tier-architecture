# aws-three-tier-architecture

<img width="427" alt="image" src="https://user-images.githubusercontent.com/108646116/219337830-8d616f22-a350-4084-a539-03317806acfb.png">

### Deploying stack
-	To run the script, after download or clone from the repository. You can either run a bash script code prepared or directly using terraform command line to deploy resources as below:

1. To deploy using script run below command and follow the instruction for deploying.
    ```
    chmod +x ops.sh
    ./ops.sh
    ```

2. To run Terraform command directly refer below.
    ```
    terraform init	
    terraform plan
    terraform deploy 
    ```
    
### Terminating stack
-	You can either run a same bash script code for terminating resources or directly using terraform command line to deploy resources as below:

1. To cleanup using script run below command and follow the instruction for resources cleanup.
    ```
    ./ops.sh
    ```

2. To run Terraform command directly refer below.
    ```
    terraform destroy
    ```

