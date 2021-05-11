# TOY-CFD for ground node


simple **6-6-6 size 3D ground Heat-transfer model**

only applicable to the ground node of 1D heat-transfer model suggested, as a module for the ground node.

<plotting of the code>


![미리보기용](https://user-images.githubusercontent.com/82522118/117624296-bb9db480-b1af-11eb-8973-7e2ba3383f19.png)
_Coded for 'Building Energy Modeling and Analysis' course of 'Civil, Environmental and Architectural Engineering, Korea .UNIV'_

***

### CAUTION
This model can be only used on the 1D heat-transfer room model. The information of the model is at below, 'room_input(2).xlsx' contains the information of the room model. In the room model, 18th node is the ground node, and cruely the heat exchange with the room(can be also said as the 1 storey bulding) and the ground are assumed as 1D heat transfer.
So the model is designed to get rid of this inaccuracy appered by the 1D heat transfer of ground node. In the model, ground node of the existing room model is deleted, and instead 244 nodes (6*6*6 meshed ground and 28 additional surface nodes) are attached
to the feet of the building. This model can be only used in this case of room model.

(lecture 14. pp2)

(room and box model in ppt)

***

### read.me


0. MATLAB is required
1.  download and place the files in **the same folder**
2.  run **'set_up.mat'**
3.  run **'Heat_transfer_3Dground_simulation.mat'**
4.  run **'Heat_transfer_3Dground_plotter.mat'**


> 'room_input(2)' contains the informations of the room we are modeling  
> 'TMY3' contains the weather data of a whole year (from January 1st to December 31st)



### CONCEPT


1.  mesh 12m * 12m * 12m sized ground with 2m interval
2.  cubes will be made by meshing (6 * 6 * 6)
3.  center of every cubes underground represents 'nodes'
4.  every nodes(= cubes) exchange heat with 6 face-to-face attached nodes (= cubes)


### KEY ASSUMPTIONS

1. The ground is made up of homogeneous soil and has the same property at any point, regardless of depth or location.

2. Ignore the shade effect by the building and surroundings. Temperatures are the same at any point on the surface.

3. Assume that underground temperature begins constant from the depth of 12 meters

4. All cubes (=nodes) produced by meshing exchange heat solely through conduction, with six other cubes (=nodes) adjacent to the face.

### ISSUES

The main purpose of heat transfer model is to predict indoor air temp under changing outdoor air temp. ODE starts to calculate from one boundary condition node to another, and the nodes that are at the path of the ODE will get the temperature difference through time as a result. **So the result of simulation unconditionally depends on the temp of boundary conditions.** In 216 nodes additionally added, 116 nodes are boundary conditions, so the ratio of boundary condition nodes in all nodes is approximately near half. **As the number of boundary condition nodes is quite large, and those 116 boundary condtion nodes' temperature are fixed, result of the simulation should be sadly inaccurate.** As it is hard to expect that there will be the data of cubes(newly defined by me), we have to simulate the boundary conditions' thermal behavior. What I suggest is to delete building part in the 3D heat transfer model, and simulate with only soil and surface nodes. With this simulation and fixed boundary condition temperature, we can get the temp difference through time and depth of the vertical nodes at the center of 12m * 12m * 12m space(in this case, (3, 3, z) nodes) as a result. Than re-input the temp data to the boundary condition nodes, depending on depth and updating through time intervals and re-simulate. The result of the vertical nodes at the cent, will converge to certain data. This data can be the temperature data of boundary condition nodes. This 'updating simulated temp data to boundary condition nodes' can be one solution.

Also, some nodes' **huge thermal mass** can be a problem when running simulation model without warmup period. In the simulations, warmup should be the basic function of the simulation because during the time needed for the nodes to reach normal temperature range from T0, accuracy of the simulation is too low. If we design warmup method in the 3D heat transfer model, crucial thing we have to consider while deciding warmup period is that **every nodes should have different time period to reach normal temp range from their initial temperature, and this time period mainly depends on their thermal mass.** If thermal mass of the node is big, it would need more time to reach normal temp range. If the thermal mass is way too big, one solution to reduce the time needed for warmup is to adjust thermal mass only on warmup period. If we adjust the thermal mass low on the warmup period, the time needed to reach the normal temp range would be short. We can use the result of this warmup to run another warmup with actual thermal mass, or we can just use the average temp of this data as T0. The warmup period dosen't need to be completely accurate, we just want to find the reasonable initial temperature by using warmup method.

These problems were not reflected to the codes. As the assumptions used are way too simple, the accuracy of the simulation is not guarangeed. More updates for the codes are needed.


***


### COMPARE

The image shows the indoor temperature difference with basic room model and 3D-added-room model.
At every time interval, _Temperature of 3D-added-room model_ minus _Temperature of basic room model_ is plotted.

![Tdiff](https://user-images.githubusercontent.com/82522118/117653559-80ab7900-b1cf-11eb-8b39-e303afb2b08b.jpg)

At time = 0 , the indoor temperature difference with basic and 3D-add in 0. This is because the warmup is not included to the 3D-added room model, so the initial temperature of indoor air is set to be the same. In december 31th, the temperature difference is approximately 0.5 degC, so we can predict the temperature difference at January 1st is similar to this result. Than, the temperature difference ranges from 0.5 degC to 2.5 degC, temp is similar even in winter, and higher in summer. At all period indoor temp of 3D-added model was higher.


### PLOT

![temp at every 2 month](https://user-images.githubusercontent.com/82522118/117654106-45f61080-b1d0-11eb-9f91-4c930bf27c0d.jpg)

[ February, August ;  
  April,    October ;  
  June,     December ] 1st at noon.

the plots shows the result of temperature of the nodes on the x=3 plane(when we define one vertex at the bottom of the 6-6-6 space as origin).


***


### PLUS

+) initial 4-4-4 model with same method. Just enlarged the sclae and made 6-6-6 heat transfer model.

![4-4-4](https://user-images.githubusercontent.com/82522118/117623624-fb17d100-b1ae-11eb-8bf2-840cedb62a71.jpg)
