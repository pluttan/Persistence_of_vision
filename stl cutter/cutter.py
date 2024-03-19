from stl import mesh
from mpl_toolkits import mplot3d
from matplotlib import pyplot

# Create a new plot
figure = pyplot.figure()
axes = mplot3d.Axes3D(figure)

# Load the STL files and add the vectors to the plot
obj = mesh.Mesh.from_file('Body1.stl')
minx = obj.x.min()
maxx = obj.x.max()
miny = obj.y.min()
maxy = obj.y.max()
minz = obj.z.min()
maxz = obj.z.max()
x=maxx-minx
y=maxy-miny
z=maxz-minz
vectors=obj.vectors
isxvectors=vectors
print(minx,maxx,miny,maxy,minz,maxz,x,y,z,vectors)
k=1
for vector in range(len(vectors)):
    for nap in range(len(vectors[vector])):
        znow=vectors[vector][nap][2]
        if znow==minz:
            vectors[vector][nap][2]=minz*k+maxz/k
        else:
            if znow>maxz/k:
                vectors[vector][nap][2]=maxz/k
                vectors[vector][nap][0]=vectors[vector][2][0]
                vectors[vector][nap][1]=vectors[vector][2][1]
obj.vectors=vectors
minx = obj.x.min()
maxx = obj.x.max()
miny = obj.y.min()
maxy = obj.y.max()
minz = obj.z.min()
maxz = obj.z.max()
x=maxx-minx
y=maxy-miny
z=maxz-minz
print(minx,maxx,miny,maxy,minz,maxz,x,y,z,vectors)
axes.add_collection3d(mplot3d.art3d.Poly3DCollection(obj.vectors))
# Auto scale to the mesh size
scale = obj.points.flatten()
axes.auto_scale_xyz(scale, scale, scale)

# Show the plot to the screen
pyplot.show()
