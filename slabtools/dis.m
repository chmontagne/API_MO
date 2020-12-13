% dis.m - slabwire CSIDISRadio class DIS analysis

% modification history
% --------------------
%                ----  v6.0.1  ----
% 10.05.07  CJM  created
%
% CJM == Joel D. Miller, Copyright Joel D. Miller (see below)

%23456789 123456789 123456789 123456789 123456789 123456789 123456789 1234567890

% Copyright (C) 2006-2018 Joel D. Miller.  All Rights Reserved.
%
% This software constitutes a "Modification" to the SLAB software system and is
% distributed under the NASA Open Source Agreement (NOSA), version 1.3.
% The NOSA has been approved by the Open Source Initiative.  See the file
% NOSA.txt at the top of the distribution directory tree for the complete NOSA
% document.

% load c:\stat.txt
% stat = load('stat_sod_525_600.txt');

% from sidisradio.cpp:
% StatEvents( "", int( this ), nState, int( m_fTRun ), int( m_fTDelay ),
%             0, m_nReadSamples[ m_nWrite ], nSamples );
%
% stat var columns
%
% 1      index
% 2   1  timestamp
% 3      time diff
% 4      object ID
% 5   2  state
% 6   3  running total
% 7   4  DIS packet delay
% 8   5  silence
% 9   6  buf samples
% 10  7  DIS packet samples

id = unique( stat(:,4) );
for k=1:length(id),
  i = find( stat(:,4) == id(k) );
  str = sprintf( 'stat%d = [ stat(i,2) stat(i,5:10) ];', k );
  eval( str );
end;

% ----  running total and DIS packet samples  ----
figure;

% running total
plot( stat1(:,1), stat1(:,3), 'b.-' );  hold on;
plot( stat2(:,1), stat2(:,3), 'g.-' );
plot( stat3(:,1), stat3(:,3), 'r.-' );
plot( stat4(:,1), stat4(:,3), 'c.-' );
plot( stat5(:,1), stat5(:,3), 'm.-' );

% DIS packet samples
plot( stat1(:,1), stat1(:,7), 'b.' );
plot( stat2(:,1), stat2(:,7), 'g.' );
plot( stat3(:,1), stat3(:,7), 'r.' );
plot( stat4(:,1), stat4(:,7), 'c.' );
plot( stat5(:,1), stat5(:,7), 'm.' );

% state
%text( stat1(:,1), stat1(:,3), num2str( stat1(:,2) ) );

title( 'running total, DIS packet samples' );
xlabel( 'secs' );
ylabel( 'ms' );
grid on;

% ----  DIS packet delay  ----
figure;

plot( stat1(:,1), stat1(:,4), 'b.-' );  hold on;
plot( stat2(:,1), stat2(:,4), 'g.-' );
plot( stat3(:,1), stat3(:,4), 'r.-' );
plot( stat4(:,1), stat4(:,4), 'c.-' );
plot( stat5(:,1), stat5(:,4), 'm.-' );

% state
text( stat1(:,1), stat1(:,4), num2str( stat1(:,2) ) );
text( stat2(:,1), stat2(:,4), num2str( stat2(:,2) ) );
text( stat3(:,1), stat3(:,4), num2str( stat3(:,2) ) );
text( stat4(:,1), stat4(:,4), num2str( stat4(:,2) ) );
text( stat5(:,1), stat5(:,4), num2str( stat5(:,2) ) );

title( 'DIS packet delay' );
xlabel( 'secs' );
ylabel( 'ms' );
grid on;

% ----  silence  ----
figure;

plot( stat1(:,1), stat1(:,5), 'b.-' );  hold on;
plot( stat2(:,1), stat2(:,5), 'g.-' );
plot( stat3(:,1), stat3(:,5), 'r.-' );
plot( stat4(:,1), stat4(:,5), 'c.-' );
plot( stat5(:,1), stat5(:,5), 'm.-' );

title( 'silence mode silence' );
xlabel( 'secs' );
ylabel( 'ms' );
grid on;

% ----  buf samples  ----
figure;

plot( stat1(:,1), stat1(:,6), 'b.-' );  hold on;
plot( stat2(:,1), stat2(:,6), 'g.-' );
plot( stat3(:,1), stat3(:,6), 'r.-' );
plot( stat4(:,1), stat4(:,6), 'c.-' );
plot( stat5(:,1), stat5(:,6), 'm.-' );

title( 'buf samples' );
xlabel( 'secs' );
ylabel( 'samples' );
grid on;

% ----  states  ----
figure;

plot( stat(:,2), stat(:,5), 'r.' );
title( 'states' );
xlabel( 'secs' );
ylabel( 'state' );
grid on;
