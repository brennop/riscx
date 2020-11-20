.data
N: .word 0, 100, 50, 305

.text
 			
 			lui s0, 0x10010 
 			lw s1, 4(s0) 		#
 			add s1, s1, s1 	
 			lw t0, 8(s0)		# 
 			sub s1, s1, t0 	
 			and t1, t0, s1 	
 			add s1, s1, t1 	
 			or t1, t0, s1		#
 			add s1, s1, t1 	
 			slt t1, t0, s1 	
 			add s1, s1, t1		
 			slt t1, s1, t0		
 			add s1, s1, t1		
 			lw t1, 12(s0)		#
 Proc:	sub s1, s1, t0
 			beq s1, t1, Proc
 			sw, s1, 0(s0)		#
 			lw, s2, 0(s0)		#
 end:		jal end				# 
