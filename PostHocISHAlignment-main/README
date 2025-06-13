ref = mcherry in vivo

Scripts:
improve_ISH_channels_alignment =  other ISH channels to mcherry ISH
align_ISH_ref = using the points created to do the alignment of mcherry in vivo to mcherry ISH 
align_time_lapse_to_ref = aligning the calcium imaging in vivo to the in vivo mcherry
prepare_CP_pairs_ISH_time_lapse = GUI for creating anchor points between mcherry ISH and mcherry in vivo

The work flow is as followed: 

1) aligning all other ISH channel images together to the mcherry ISH (improve_ISH_channels_alignment)
2) aligning in vivo calcium imaging to the mcherry in vivo image taken (align_time_lapse_to_ref)
* steps 1 and 2 can be done in either order 
3) create anchor points between the mcherry ISH to mcherry in vivo (8-10 points spread out across the entire TG) (prepare_CP_pairs_ISH_time_lapse)
4) run the ISH to in vivo script to align the mcherry ISH to in vivo (align_ISH_ref)
5) circle all electrical responders and save as ROIs (ImageJ)
6) overlay ROIs over the in situ image and ensure alignment went well by comparing that the morphology of each cell is the same
7) calculate the percentage of cells positive for each marker 
