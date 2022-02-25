#!/usr/bin/perl

$gnuplot = "/usr/bin/gnuplot";
$ppmtogif = "/usr/local/netpbm/ppmtogif";

$process_id = $$;
$output_ppm =join ("", "/tmp/", $process_id, ".ppm");

&parse_form_data (*FORM);

$x = 1;
$y = 1;
$color = 1;

$funcion = $FORM{'funcion'};

&send_data_to_gnuplot();
print `rm $output_ppm`;

exit (0);

sub send_data_to_gnuplot
{
	open (GNUPLOT, "|$gnuplot");
	print GNUPLOT <<gnuplot_final;
set term pbm color small
set output "$output_ppm"
set size $x, $y
#set title "Uso del disco duro"
#set xlabel "Usuarios"
#set ylabel "Espacio Ocupado en Megabytes"
#set xrange [-1:10]
#set xtics ("$nombres[0]" 0, "$nombres[1]" 1, "$nombres[2]" 2, "$nombres[3]" 3, "$nombres[4]" 4, "$nombres[5]" 5, "$nombres[6]" 6, "$nombres[7]" 7, "$nombres[8]" 8, "$nombres[9]" 9)
#set noxzeroaxis
#set noyzeroaxis
#set border
#set nogrid
#set nokey
splot $funcion
#w boxes $color

gnuplot_final

close (GNUPLOT);

&print_gif_file_and_cleanup();
}

sub print_gif_file_and_cleanup
{
$| = 1;
print "Content-type: image/gif" , "\n\n";
system ("$ppmtogif $output_ppm 2> /dev/null");

#unlink $output_ppm, $datafile;
}

sub parse_form_data
{
local (*FORM_DATA) = @_;

local ( $request_method, $query_string, @key_value_pairs, $key_value, $key,
$value);

$request_method = $ENV{'REQUEST_METHOD'};

if ($request_method eq "GET") {
 	$query_string = $ENV{'QUERY_STRING'};
} elsif ($request_method eq "POST") {
 	read (STDIN, $query_string, $ENV{'CONTENT_LENGTH'});
} else {
 	&return_error (500, "Error en el Servidor", "El servidor no soporta
 el Metodo de traspaso Utilizado");
}

@key_value_pairs = split (/&/, $query_string);

foreach $key_value (@key_value_pairs) {
	($key, $value) = split (/=/, $key_value);
	$value =~ tr/+/ /;
	$value =~ s/%([\dA-Fa-f][\dA-Fa-f])/pack ("C", hex ($1))/eg;

	if (defined($FORM_DATA{$key})) {
		$FORM_DATA{$key} = join ("\0", $FORM_DATA{$key}, $value);
	} else {
		$FORM_DATA{$key} = $value;
	}
}
}

sub return_error
{
	local ($status, $keyword, $message) = @_;

	print "Content-type: text/html", "\n";
	print "Status: ", $status, " ", $keyword, "\n\n";

	print <<Fin_Error;

<TITLE>Programa CGI - Error Inesperado</TITLE>
<H1>$keyword</H1>
<HR>$message</HR>
Contactar a <A HREF = mailto:root\@pamela.efn.uncor.edu>root\@pamela.efn.uncor.edu
</A>por informaci&oacute.

Fin_Error

	exit(1);
}