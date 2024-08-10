<!DOCTYPE html>
<html lang="en">

<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title><%= $filename %></title>

	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css" rel="stylesheet">
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/codemirror@5.65.11/lib/codemirror.min.css">
	<script src="https://cdn.jsdelivr.net/npm/codemirror@5.65.11/addon/runmode/runmode-standalone.min.js" defer>
	</script>
	<script src="<%= $pg_doc_home %>/PG.js" defer></script>
	<link rel="stylesheet" href="<%= $pg_doc_home %>/sample-problem.css" >
</head>

% # Default explanations
% my $default = {
	% preamble  => 'These standard macros need to be loaded.',
	% setup     => 'This perl code sets up the problem.',
	% statement => 'This is the problem statement in PGML.',
	% answer    => 'This is used for answer checking.',
	% solution  => 'A solution should be provided here.'
% };

<body>
	<div class="container-fluid p-3">
		<div class="row">
			<div class="col">
				<h1><%= $name %></h1>
				<p><%= $description %></p>
			</div>
			<div class="col text-end">
				<a href="<%= $pg_doc_home =%>/../">Return to the PG docs home</a>
			</div>
		</div>
		<div class="row">
			<div class="col">
				<h2>Complete Code</h2>
				<p>
				Download file: <a href="<%= $filename =%>"><%= $filename =%></a>
				</p>
			</div>
			% if (scalar(@{$metadata->{$filename}{macros}}) > 0 ) {
				<div class="col">
					<h2>POD for Macro Files</h2>
					<ul>
						% for my $macro (@{$metadata->{$filename}{macros}}) {
							% if ($macro_locations->{$macro}) {
								<li><a href="<%= $pod_root %>/<%= $macro_locations->{$macro} %>"><%= $macro =%></a></li>
							% } else {
								<li class="text-danger"><%= $macro %></li>
							% }
						% }
					</ul>
				</div>
				%}
			% if ($metadata->{$filename}{related} && scalar(@{$metadata->{$filename}{related}}) > 0) {
			<div class="col">
				<h2>See Also</h2>
				<ul>
					% for (@{$metadata->{$filename}{related}}) {
						<li><a href="<%= $pg_doc_home =%>/<%= $metadata->{$_}{dir} =%>/<%= $_ =~ s/.pg$//r =%>.html">
							<%= $metadata->{$_}{name} =%></a></li>
					% }
				</ul>
			</div>
			% }
		</div>
		<div class="row">
			<div class="col text-center"><h2 class="fw-bold fs-3">PG problem file</h2></div>
			<div class="col text-center"><h2 class="fw-bold fs-3">Explanation</h2></div>
		</div>
		% for (@$blocks) {
			<div class="row">
				<div class="col-sm-12 col-md-6 order-md-first order-last p-0 position-relative overflow-x-hidden">
					<button class="clipboard-btn btn btn-sm btn-secondary position-absolute top-0 end-0 me-1 mt-1 z-1"
						type="button" data-code="<%== $_->{code} %>" aria-label="copy to clipboard">
						<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor"
							class="bi bi-clipboard-fill" viewBox="0 0 16 16">
							<path fill-rule="evenodd" d="M10 1.5a.5.5 0 0 0-.5-.5h-3a.5.5 0 0 0-.5.5v1a.5.5 0 0 0 .5.5h3a.5.5 0 0 0 .5-.5v-1Zm-5 0A1.5 1.5 0 0 1 6.5 0h3A1.5 1.5 0 0 1 11 1.5v1A1.5 1.5 0 0 1 9.5 4h-3A1.5 1.5 0 0 1 5 2.5v-1Zm-2 0h1v1A2.5 2.5 0 0 0 6.5 5h3A2.5 2.5 0 0 0 12 2.5v-1h1a2 2 0 0 1 2 2V14a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V3.5a2 2 0 0 1 2-2Z"/>
						</svg>
					</button>
					<pre class="CodeMirror cm-s-default m-0 h-100 p-3 border border-secondary overflow-x-scroll"><%== $_->{code} %></pre>
				</div>
				<div class="explanation <%= $_->{section} %> col-sm-12 col-md-6 order-md-last order-first p-3 border border-dark">
					<p><b><%= ucfirst($_->{section}) %></b></p>
					% if ($_->{doc}) {
						<%= $_->{doc} %>
					%} else {
						<%= $default->{$_->{section}} %>
					%}
				</div>
			</div>
		% }
	</div>

	<script type="module">
		for (const pre of document.body.querySelectorAll('pre.CodeMirror')) {
			CodeMirror.runMode(pre.textContent, 'PG', pre);
		}

		for (const btn of document.querySelectorAll('.clipboard-btn')) {
			if (navigator.clipboard) btn.addEventListener('click', () => navigator.clipboard.writeText(btn.dataset.code));
			else btn?.remove();
		}
	</script>
</body>

</html>
