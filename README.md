# 6-6-6-3D-Heat-transfer-model


simple **6-6-6 size 3D ground Heat-transfer model**

with unsteady 2D heat-transfer room model

<plotting of the code>


![plott](https://user-images.githubusercontent.com/82522118/117552847-dcb7b580-b088-11eb-83df-c9eabe4a2556.png)
_Coded for 'Building Energy Modeling and Analysis' course of 'School of Civil, Environmenta and Architectural Engineering, Korea .UNIV'_

***


### read.me


0. MATLAB is required
1.  download and place the files in **the same folder**
2.  run **'set_up.mat'**
3.  run **'Heat_transfer_3Dground_simulation.mat'**
4.  run **'Heat_transfer_3Dground_plotter.mat'**


> 'room_input(2)' contains the informations of the room we are modeling  
> 'TMY3' contains the weather data of a whole year (from January 1st to December 31st)



### Concept 


1.  mesh 12m * 12m * 12m sized ground with 2m interval
2.  cubes will be made by meshing the ground (6 * 6 * 6)
3.  center of the cubes represents 'nodes'
4.  every nodes(= cubes) exchange heat with 6 face-to-face attached nodes (= cubes)



### Plus
In simulating this unsteady heat-transfer model, most problems appeared on 'Thermal mass'.  Ground's thermal mass is too big that if T0 of the nodes were set far from their normal temperature range, the simulation should need more than a year to finish warmup. Mesh wasn't finely set enough, so boundary condition nodes effected too much on other non-boundary nodes, and because the thermal mass of the ground nodes are too big, the effect of boundary condition nodes began worse.
