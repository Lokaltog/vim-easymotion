" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

function! EasyMotion#init#InitOptions(options) " {{{
	for [key, value] in items(a:options)
		if ! exists('g:EasyMotion_' . key)
			exec 'let g:EasyMotion_' . key . ' = ' . string(value)
		endif
	endfor
endfunction " }}}

function! EasyMotion#init#InitHL(group, colors) " {{{
	let group_default = a:group . 'Default'

	" Prepare highlighting variables
	let guihl = printf('guibg=%s guifg=%s gui=%s', a:colors.gui[0], a:colors.gui[1], a:colors.gui[2])
	if !exists('g:CSApprox_loaded')
		let ctermhl = &t_Co == 256
			\ ? printf('ctermbg=%s ctermfg=%s cterm=%s', a:colors.cterm256[0], a:colors.cterm256[1], a:colors.cterm256[2])
			\ : printf('ctermbg=%s ctermfg=%s cterm=%s', a:colors.cterm[0], a:colors.cterm[1], a:colors.cterm[2])
	else
		let ctermhl = ''
	endif

	" Create default highlighting group
	execute printf('hi default %s %s %s', group_default, guihl, ctermhl)

	" Check if the hl group exists
	if hlexists(a:group)
		redir => hlstatus | exec 'silent hi ' . a:group | redir END

		" Return if the group isn't cleared
		if hlstatus !~ 'cleared'
			return
		endif
	endif

	" No colors are defined for this group, link to defaults
	execute printf('hi default link %s %s', a:group, group_default)
endfunction " }}}

function! EasyMotion#init#InitMappings(motions, do_mapping) "{{{
	for [motion, fn] in items(a:motions)
		" Prepare <Plug> mapping {{{
		silent exec 'nnoremap <silent>
			\ <Plug>(easymotion-' . motion . ')
			\ :call EasyMotion#' . fn.name . '(0, ' . fn.dir . ')<CR>'
		silent exec 'onoremap <silent>
			\ <Plug>(easymotion-' . motion . ')
			\ :call EasyMotion#' . fn.name . '(0, ' . fn.dir . ')<CR>'
		silent exec 'vnoremap <silent>
			\ <Plug>(easymotion-' . motion . ')
			\ :<C-u>call EasyMotion#' . fn.name . '(1, ' . fn.dir . ')<CR>'
		"}}}

		" Do mapping {{{
		if a:do_mapping && !hasmapto('<Plug>(easymotion-' . motion . ')')
			silent exec 'map <silent> ' .
				\ g:EasyMotion_leader_key . motion . ' <Plug>(easymotion-' . motion . ')'
		endif "}}}

		" Backward compatible mapping {{{
		if exists('g:EasyMotion_mapping_' . motion)
			silent exec 'map <silent> ' .
				\ eval('g:EasyMotion_mapping_' . motion) . ' <Plug>(easymotion-' . motion . ')'
		endif "}}}
	endfor
endfunction "}}}

function! EasyMotion#init#InitSpecialMappings(motions, do_mapping) "{{{
	for [motion, fn] in items(a:motions)
		silent exec 'onoremap <silent>
			\ <Plug>(easymotion-special-' . motion . ') :call EasyMotion#' . fn.name . '()<CR>'
		silent exec 'vnoremap <silent>
			\ <Plug>(easymotion-special-' . motion . ') :<C-u>call EasyMotion#' . fn.name . '()<CR>'
		silent exec 'nnoremap <silent>
			\ y<Plug>(easymotion-special-' . motion . ') :call EasyMotion#' . fn.name . 'Yank()<CR>'
		silent exec 'nnoremap <silent>
			\ d<Plug>(easymotion-special-' . motion . ') :call EasyMotion#' . fn.name . 'Delete()<CR>'

		" Do mapping {{{
		if a:do_mapping && !hasmapto('<Plug>(easymotion-special-' . motion . ')')
			silent exec 'omap <silent> ' .
				\ g:EasyMotion_leader_key . motion . ' <Plug>(easymotion-special-' . motion . ')'
			silent exec 'xmap <silent> ' .
				\ g:EasyMotion_leader_key . motion . ' <Plug>(easymotion-special-' . motion . ')'
			silent exec 'nmap <silent> ' .
				\ 'd' . g:EasyMotion_leader_key . motion . ' d<Plug>(easymotion-special-' . motion . ')'
			silent exec 'nmap <silent> ' .
				\ 'y' . g:EasyMotion_leader_key . motion . ' y<Plug>(easymotion-special-' . motion . ')'
		endif "}}}
	endfor
endfunction "}}}

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
unlet s:save_cpo
" }}}
" vim: fdm=marker:noet:ts=4:sw=4:sts=4
