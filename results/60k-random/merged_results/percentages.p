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

  plot "/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-05-23-24-54//percentages.csv.fixed" with lines title "localhost:12080 - 2024-12-05-23-24-54","/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-05-23-26-01//percentages.csv.fixed" with lines title "localhost:12080 - 2024-12-05-23-26-01","/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-05-23-27-12//percentages.csv.fixed" with lines title "localhost:12080 - 2024-12-05-23-27-12","/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-05-23-25-26//percentages.csv.fixed" with lines title "localhost:12080 - 2024-12-05-23-25-26","/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-05-23-26-38//percentages.csv.fixed" with lines title "localhost:12080 - 2024-12-05-23-26-38",
