function E = anyExceed(X, L, H, varargin)
% Check if any element exceeds upper or lower limit
% Equivalent Matlab expression:
%   any(Array(:) < Lower) || any(Array(:) > Upper)
% This Mex is faster for large arrays, because it does not create temporary
% logical arrays and returns after the first match is found.
%
% Flag = anyExceed(Array, Lower, Upper, Options...)
% INPUT:
%   Array:  Array of any size. Accepted classes: DOUBLE, SINGLE, INT8, UINT8,
%           INT16, UINT16, INT32, UINT32, CHAR.
%           NaN's in [Array] are ignored in every case:
%             anyExceed(NaN, U, L) replies FALSE for all U and L.
%   Lower, Upper: Limits as scalar values of the same type as Array. The limits
%           are sorted automatically, such that Lower <= Upper.
%   Options: Optional strings to control the comparison. The order is arbitrary
%           and all options can be combined. Just the first character is
%           compared:
%           'finite':   +-Inf values in [Array] are ignored.
%           'absolute': Compare absolute values of Array elements.
%           'exclude':  Exclude the limits also:
%                       Flag = any(Array(:) <= Lower) || any(Array(:) >= Upper)
%
% OUTPUT:
%   Flag:  TRUE if any element exceeds the limits, FALSE otherwise.
%
% EXAMPLES:
%   anyExceed(rand(1000), 0, 1)              % FALSE
%   anyExceed(0:0.1:1, 0, 1, 'exclude')      % TRUE
%   anyExceed([1, Inf, 2], 0, 2, 'finite')   % FALSE
%   anyExceed(-10:10, 0, 10, 'abs')          % FALSE
%   anyExceed(-10:10, -1, 10, 'abs', 'ex')   % TRUE
%
% NOTES:
%   Especially for large arrays this function is more efficient than the
%   equivalent Matlab method, because it does not create temporary arrays.
%
% COMPILE:
%   Windows: mex -O anyExceed.c
%   Linux:   mex -O CFLAGS="\$CFLAGS -std=c99" anyExceed.c
%   Precompiled Mex: http://www.n-simon.de/mex
%   See anyExceed.c for more information.
%
% Tested: Matlab 6.5, 7.7, 7.8, 7.13, WinXP/32, Win7/64
%         Compatibility with Linux, OS-X and 64 bit addressing is assumed.
% Compiler: BCC5.5, LCC2.4/3.8, Open Watcom 1.8, MSVC 2008
% Author: Jan Simon, Heidelberg, (C) 20010 matlab.THISYEAR(a)nMINUSsimon.de
% $JRev: R-h V:007 Sum:d/s0G+8gvYuf Date:03-Oct-2011 17:48:40 $
% $License: BSD (use/copy/change/redistribute on own risk, mention the author) $
% $UnitTest: uTest_anyExceed $
% $File: Tools\GLSets\anyExceed.m $
% History:
% 001: 09-Jun-2010 16:25, M-file to offer help.
% Initialize: ==================================================================
% warning('JSimon:anyExceed:NoMex', ...
%  'The slow Matlab version of anyExceed is used instead of fast MEX.');
% Do the work: =================================================================
% Pure Matlab function for testing. This is always slower than the direct
% ANY(X<L) || ANY(X>U) approach.
% Sort limits:
if L > H
   tmp = H;
   H   = L;
   L   = tmp;
end
X = X(:);
if sscanf(version, '%d', 1) < 7 && isa(X, 'single')
   % Matlab 6.5 bug: NaN < a replied TRUE
   X = X(not(isnan(X)));
end
if nargin == 3
   E = any(X < L) || any(X > H);
else
   C = varargin;
   if any(strncmpi(C, 'f', 1))
      X = X(isfinite(X));
   end
   if any(strncmpi(C, 'a', 1))
      % No ABS for (U)INT8/16/32 under Matlab 6.5...
      neg    = (X < 0);
      X(neg) = -double(X(neg));  % No unary minus in Matlab 6 also.
   end
   if any(strncmpi(C, 'e', 1))
      E = any(X <= L) || any(X >= H);
   else
      E = any(X < L)  || any(X > H);
   end
end
% return;