%%
%% Chandra_15yrs_ex3.sl : One of three examples from our poster at the
%%                        15 Years of Chandra symposium
%%
%% Created 2014.11.11   : lia@space.mit.edu
%%

require("xstardb");

%%----------------------------------------------------------------
%% Example 3: Run a grid of photemis models over rlogxi

%% 1. Set up the model parameters

%% To run a set of XSTAR models, you need to create two structures: a wavelength grid,

variable x1, x2;
(x1, x2) = linear_grid( 1.0, 40.0, 10000 );
variable model_binning = struct{ bin_lo=x1, bin_hi=x2 };

%% and a structure containing model information. 

%% The built in variable _default_model_info is an empty structure
%% with all the necessary fields. In this example, we set up a
%% photemis model grid over rlogxi = -2 to +2, using 0.05 spaced
%% sample points.

variable model_info    = @_default_model_info;
set_struct_fields( model_info, "photemis", "rlogxi", -2.0, 2.0, 0.1, model_binning );

%% WARNING: This will take awhile (~20 minutes on my machine)
%% Comment out the line below if you have already run the model grid
%xstar_run_model_grid( model_info, "/vex/d1/lia/rlogxi_example/"; nstart=10 );
%% ^If you are running more than 10 models, you should choose a
%% double-digit number for nstart, so the filenames can be sorted
%% properly by array_sort (below)


%% 2. Load the models into a gridded database structure
variable fgrid, pe_grid;

fgrid = glob( "/nfs/vex/d1/lia/rlogxi_example/photemis_*.fits" );
fgrid = fgrid[ array_sort(fgrid) ];

pe_grid = xstar_load_tables( fgrid );

%% The database grid structure contains several important fields.
%% For this example:
%%  - pe_grid.mdb is a "master database" structure containing information about each unique transition found
%%  - pe_grid.uids contains an array of long integers assigning a "unique id" value to each transitions (see below)
%%  - pe_grid.db is an array of database structures (in the order specified by fgrid)
%%  - pe_grid.db[n].uid contains the unique ids for each transition in this individual XSTAR run


%% 3. Look for the o_vii triplet

%% Each transition is assigned a "unique id" based on the ion, lower
%% level, and upper level.  These properties are indexed with integers
%% ind_ion, ind_lo, and ind_up (see e.g. xstarlevels.txt)

%% We will use this fact to look for the O VII triplet.

variable o_vii = where( xstar_el_ion(pe_grid.mdb, O, 7) );
xstar_page_grid( pe_grid, o_vii );

%% To look for index values associated with the forbidden line of the
%% O VII He-like triplet, we can print the information directly from
%% the structure, e.g. print(pe_grid[o_vii].ind_lo);

%% One can also use the built-in function:
xstar_page_id( pe_grid, o_vii );

%% Let's track the luminosity of the forbidden line as it changes with rlogxi
%% The lower and upper index values for that transition are 1 and 2, respectively

variable o_vii_F = where(xstar_trans( pe_grid.mdb, O, 7, 1, 2 ));
variable o_vii_F_lum = xstar_line_prop( pe_grid, o_vii_F, "luminosity" );
variable rlogxi  = xstar_get_grid_par( pe_grid, "rlogxi" );

% Plot it
xlabel( latex2pg( "rlog\\xi" ) );
ylabel( latex2pg( "Luminosity [10^{38} cgs]" ) );
title( pe_grid.mdb.transition_name[o_vii_F][0] );
plot( rlogxi, o_vii_F_lum, 3 );




