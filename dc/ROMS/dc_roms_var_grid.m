%       [xax,yax,zax,tax,xunits,yunits,grd] = roms_var_grid(fname,varname)
% returns grids as matrices of appropriate size for variable

function [xax,yax,zax,tax,xunits,yunits,grd] = dc_roms_var_grid(fname,varname,tindex)

    warning off;

    if ~exist('tindex','var'), tindex = 0; end
    
    if isstruct(fname)
        grd = fname;
        fname = grd.grd_file;
    else
        grd = roms_get_grid(fname,fname,tindex,1);
    end
    
    if strcmpi(varname,'pv')
        pos = 'p';
    elseif strcmpi(varname,'eke') || strcmp(varname,'mke') || strcmp(varname,'pe')
        pos = 'e';
    elseif strcmpi(varname,'rv')
        pos = 'q';
    else
        % from John Wilkin's roms_islice.m
        % determine where on the C-grid these values lie
        try
            varcoords = nc_attget(fname,varname,'coordinates');
        catch ME
            if strcmpi(varname,'rho') || strcmpi(varname,'temp') || ...
                    strcmpi(varname,'salt')
                varcoords = '_rho';
            end
        end

        if ~isempty(strfind(varcoords,'_u'))
          pos = 'u';
        elseif ~isempty(strfind(varcoords,'_v'))
          pos = 'v';
        elseif ~isempty(strfind(varcoords,'_w'))
          pos = 'w';
        elseif ~isempty(strfind(varcoords,'_rho'))
          pos = 'r'; % rho
        else
          error('Unable to parse the coordinates variables to know where the data fall on C-grid')
        end

    N = size(grd.z_r,1);
    end

    switch pos
        case 'u'
          if ~isempty(grd.lon_u)
            xax = repmat(grd.lon_u',[1 1 N]);
            yax = repmat(grd.lat_u',[1 1 N]);
          else
            xax = repmat(grd.x_u',[1 1 N]);
            yax = repmat(grd.x_u',[1 1 N]);
          end
          zax = permute(grd.z_u,[3 2 1]);
          tax = ncread(fname,'ocean_time');

          try
              xunits = ncreadatt(fname,'lon_u','units');
              yunits = ncreadatt(fname,'lat_u','units');
          catch ME
              xunits = ncreadatt(fname,'x_u','units');
              yunits = ncreadatt(fname,'y_u','units');
          end

        case 'v'
            if ~isempty(grd.lon_v)
                xax = repmat(grd.lon_v',[1 1 N]);
                yax = repmat(grd.lat_v',[1 1 N]);
            else
                xax = repmat(grd.x_v',[1 1 N]);
                yax = repmat(grd.y_v',[1 1 N]);
            end
            zax = permute(grd.z_v,[3 2 1]);
            tax = ncread(fname,'ocean_time');

            try
                xunits = ncreadatt(fname,'lon_v','units');
                yunits = ncreadatt(fname,'lat_v','units');
            catch ME
                xunits = ncreadatt(fname,'x_v','units');
                yunits = ncreadatt(fname,'y_v','units');
            end

        case 'w'
            if ~isempty(grd.lon_rho)
                xax = repmat(grd.lon_rho',[1 1 N+1]);
                yax = repmat(grd.lat_rho',[1 1 N+1]);
            else
                xax = repmat(grd.x_rho',[1 1 N+1]);
                yax = repmat(grd.y_rho',[1 1 N+1]);
            end
            zax = permute(grd.z_w,[3 2 1]);
            tax = ncread(fname,'ocean_time');

            try
                xunits = ncreadatt(fname,'lon_rho','units');
                yunits = ncreadatt(fname,'lat_rho','units');
            catch ME
                xunits = ncreadatt(fname,'x_rho','units');
                yunits = ncreadatt(fname,'y_rho','units');
            end

        case 'r'

            tax = ncread(fname,'ocean_time');

            if strcmp(varname, 'zeta');
                if ~isempty(grd.lon_rho)
                    xax = grd.lon_rho';
                    yax = grd.lat_rho';
                else
                    xax = repmat(grd.x_rho',[1 1 N+1]);
                    yax = repmat(grd.y_rho',[1 1 N+1]);
                end
                zax = [];
            else
                if ~isempty(grd.lon_rho)
                    xax = repmat(grd.lon_rho',[1 1 N]);
                    yax = repmat(grd.lat_rho',[1 1 N]);
                else
                    xax = repmat(grd.x_rho',[1 1 N+1]);
                    yax = repmat(grd.y_rho',[1 1 N+1]);
                end
                zax = permute(grd.z_r,[3 2 1]);
            end

            try
                xunits = ncreadatt(fname,'lon_rho','units');
                yunits = ncreadatt(fname,'lat_rho','units');
            catch ME
                xunits = ncreadatt(fname,'x_rho','units');
                yunits = ncreadatt(fname,'y_rho','units');
            end

        case 'p'
            xax = ncread(fname,'x_pv');
            yax = ncread(fname,'y_pv');
            zax = ncread(fname,'z_pv');
            tax = ncread(fname,'ocean_time');

            xunits = ncreadatt(fname,'x_pv','units');
            yunits = ncreadatt(fname,'y_pv','units');

       case 'e'
            xax = ncread(fname,'x_en');
            yax = ncread(fname,'y_en');
            zax = ncread(fname,'z_en');
            tax = ncread(fname,'t_en');
            xunits = ncreadatt(fname,'x_en','units');
            yunits = ncreadatt(fname,'y_en','units');

       case 'q'
            xax = ncread(fname,'x_rv');
            yax = ncread(fname,'y_rv');
            zax = ncread(fname,'z_rv');
            tax = ncread(fname,'ocean_time');
            xunits = ncreadatt(fname,'x_rv','units');
            yunits = ncreadatt(fname,'y_rv','units');
    end

    xunits = strrep(xunits,'_',' ');
    yunits = strrep(yunits,'_',' ');

    warning on;
