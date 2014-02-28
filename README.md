Visualizing-Growth-of-German-PV
===============================

Code used for creating <a href="http://www.youtube.com/watch?v=XpvQNn0n_Qw">Time lapse of 860,000 photovoltaic systems installed across Germany</a>.

Also see a <a href="https://www.youtube.com/watch?v=R0vbbwgGV70">similar example for the UK</a>, which was done by <a href="http://www3.imperial.ac.uk/people/j.keirstead">James Keirstead</a>.

German postcode data is sourced from Geonames - http://download.geonames.org/export/zip/

<a href="http://www.youtube.com/watch?v=XpvQNn0n_Qw"><img src="https://raw.github.com/cbdavis/Visualizing-Growth-of-German-PV/master/GermanPV.png"></a>

Movie is rendered using mencoder
<pre>
opt="vbitrate=24000000:mbd=2:keyint=132:vqblur=1.0:cmp=2:subcmp=2:dia=2:mv0:last_pred=3"
mencoder -ovc lavc -lavcopts vcodec=mpeg4:vpass=1:$opt -mf type=png:fps=20 -nosound -o /dev/null mf://0*.png
mencoder -ovc lavc -lavcopts vcodec=mpeg4:vpass=2:$opt -mf type=png:fps=20 -nosound -o GermanPV.avi mf://0*.png
</pre>
