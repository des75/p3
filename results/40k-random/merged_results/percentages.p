# output as png image
	set terminal png size 1024,768 crop

	# save file to benchmark.png
	set output "merged_percentages.png"

	# graph a title
	set title "Merged Test Results"

	# nicer aspect ratio for image size
	set size 1,0.7

	# y-axis grid
	set grid y

	# x-axis label
	set xlabel "Percentiles"

	# y-axis label
	set ylabel "Response time \(ms\)"

  set pointsize 1

	set datafile separator ","

  plot "/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-05-22-52-39/percentages.csv.fixed" with lines title "localhost:12080 - 2024-12-05-22-52-39","/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-05-22-52-59/percentages.csv.fixed" with lines title "localhost:12080 - 2024-12-05-22-52-59","/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-05-22-53-22/percentages.csv.fixed" with lines title "localhost:12080 - 2024-12-05-22-53-22","/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-05-22-53-47/percentages.csv.fixed" with lines title "localhost:12080 - 2024-12-05-22-53-47","/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-05-22-54-15/percentages.csv.fixed" with lines title "localhost:12080 - 2024-12-05-22-54-15",
