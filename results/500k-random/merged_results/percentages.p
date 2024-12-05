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

  plot "/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-05-23-57-43/percentages.csv.fixed" with lines title "localhost:12080 - 2024-12-05-23-57-43","/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-06-00-03-32/percentages.csv.fixed" with lines title "localhost:12080 - 2024-12-06-00-03-32","/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-06-00-06-27/percentages.csv.fixed" with lines title "localhost:12080 - 2024-12-06-00-06-27","/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-06-00-08-13/percentages.csv.fixed" with lines title "localhost:12080 - 2024-12-06-00-08-13","/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-06-00-09-28/percentages.csv.fixed" with lines title "localhost:12080 - 2024-12-06-00-09-28",
