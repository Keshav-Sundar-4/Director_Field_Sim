from fenics import *
import matplotlib.pyplot as plt
import numpy as np

# Parameters
gamma = 1.0  # Damping coefficient, modifiable
K = 0.1      # Elastic constant, modifiable
beta = 0.05  # Interaction parameter, modifiable

# Create mesh and define function space
mesh = UnitSquareMesh(50, 50)
V = VectorFunctionSpace(mesh, 'P', 1)

# Define boundary conditions
# Assuming a simple case where the director field on the boundary is zero
bc = DirichletBC(V, Constant((0, 0)), 'on_boundary')

# Define initial conditions
Q_init = Expression(('x[0]*x[0] - x[1]*x[1]', '2*x[0]*x[1]'), degree=2)
Q = interpolate(Q_init, V)

# Define test functions
v = TestFunction(V)
dQ = TrialFunction(V)

# Define variational problem
a = gamma*inner(dQ, v)*dx
L = -inner(Q, v)*dx + K*inner(grad(Q), grad(v))*dx

# Include the interaction term (simplified for illustrative purposes)
c = Expression('sin(2*pi*x[0])', degree=2)  # Simulated morphogen concentration
L += beta*inner(as_tensor(((grad(c)[0]*grad(c)[0], grad(c)[0]*grad(c)[1]), 
                           (grad(c)[1]*grad(c)[0], grad(c)[1]*grad(c)[1])), v))*dx

# Assemble system
Q_new = Function(V)
solve(a == L, Q_new, bc)

# Convert to numpy arrays for plotting
coordinates = mesh.coordinates()
x, y = coordinates[:, 0], coordinates[:, 1]
u, v = Q_new.split(deepcopy=True)  # Split the components of the vector field

# Interpolating to grid for plotting
u_values = u.compute_vertex_values(mesh)
v_values = v.compute_vertex_values(mesh)

plt.figure(figsize=(8, 8))
plt.quiver(x, y, u_values, v_values, scale=50)
plt.title('Director Field Visualization')
plt.xlabel('X Coordinate')
plt.ylabel('Y Coordinate')
plt.show()
