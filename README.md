Visualizing-Growth-of-German-PV
===============================

Code used for creating <a href="http://www.youtube.com/watch?v=XpvQNn0n_Qw">Time lapse of 860,000 photovoltaic systems installed across Germany</a>.  Aside from rendering the frames, it first downloads the source data (multiple Excel spreadsheets from Bundesnetzagentur listed <a href=http://www.bundesnetzagentur.de/cln_1911/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/ErneuerbareEnergien/Photovoltaik/DatenMeldgn_EEG-VergSaetze/DatenMeldgn_EEG_VergSaetze.html>here</a> and <a href=http://www.bundesnetzagentur.de/cln_1911/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/ErneuerbareEnergien/Photovoltaik/ArchivDatenMeldgn/ArchivDatenMeldgn_node.html>here</a>), and then recombines them into a single table, which is then exported to a csv file and zipped up (available <a href=https://github.com/cbdavis/Visualizing-Growth-of-German-PV/raw/master/PV_Capacity_Installed_by_PostCode_Date_and_Coordinates.csv.zip>here</a>)

Also see a <a href="https://www.youtube.com/watch?v=R0vbbwgGV70">similar example for the UK</a>, which was done by <a href="http://www3.imperial.ac.uk/people/j.keirstead">James Keirstead</a>.

German postcode data is sourced from Geonames - http://download.geonames.org/export/zip/

<a href="http://www.youtube.com/watch?v=XpvQNn0n_Qw"><img src="https://raw.github.com/cbdavis/Visualizing-Growth-of-German-PV/master/GermanPV.png"></a>

Movie is rendered using mencoder
<pre>
opt="vbitrate=24000000:mbd=2:keyint=132:vqblur=1.0:cmp=2:subcmp=2:dia=2:mv0:last_pred=3"
mencoder -ovc lavc -lavcopts vcodec=mpeg4:vpass=1:$opt -mf type=png:fps=20 -nosound -o /dev/null mf://0*.png
mencoder -ovc lavc -lavcopts vcodec=mpeg4:vpass=2:$opt -mf type=png:fps=20 -nosound -o GermanPV.avi mf://0*.png
</pre>
