% if ($type eq 'techniques') {
	% for (['A' .. 'C'], ['D' .. 'F'], ['G' .. 'N'], ['O' .. 'Z']) {
		<div class="tab-pane fade" id="<%= $_->[0] %>" role="tabpanel" aria-labelledby="<%= $_->[0] %>-tab" tabindex="0">
			<h1 class="fs-3">Sample Problems for Techniques: <%= $_->[0] %> .. <%= $_->[-1] %></h1>
			<ul>
				% my $b = join('', @$_);
				% for (sort grep { substr($_, 0, 1 ) =~ qr/^[$b]/i } keys(%$list)) {
					<li><a href="<%= $list->{$_} =%>"><%= $_ =%></a></li>
				% }
			</ul>
		</div>
	% }
% } else {
	% for (sort(keys %$list)) {
		% my %topics = (categories => 'Catetory', subjects => 'Subject', macros => 'Macro');
		% my $id = $_ =~ s/\s/_/gr;
		<div class="tab-pane fade" id="<%= $id %>" role="tabpanel" aria-labelledby="<%= $id %>-tab"
			tabindex="0">
			<h1 class="fs-3">Sample Problems for <%= $topics{$type} %>: <%= $_ %></h1>
			<ul>
				% for my $link (sort (keys %{$list->{$_}})) {
					<li><a href="<%= $list->{$_}{$link} =%>"><%= $link %></a></li>
				% }
			</ul>
		</div>
	% }
% }
