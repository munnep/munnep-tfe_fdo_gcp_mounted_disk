from diagrams import Cluster, Diagram
from diagrams.onprem.compute import Server


from diagrams.gcp.compute import ComputeEngine



# Variables
title = "VPC with 1 public subnet for the TFE server"
outformat = "png"
filename = "diagram_tfe_fdo_gcp_mounted_disk"
direction = "TB"


with Diagram(
    name=title,
    direction=direction,
    filename=filename,
    outformat=outformat,
) as diag:
    # Non Clustered
    user = Server("user")

    # Cluster 
    with Cluster("gcp"):
        with Cluster("vpc"):
          with Cluster("subnet_public1"):
            ec2_tfe_server = ComputeEngine("TFE_server")
               
    # Diagram

    user >> [ec2_tfe_server]
   
diag
