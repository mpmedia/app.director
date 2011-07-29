<?php
/**
 *
 * PHP versions 4 and 5
 *
 * CakePHP(tm) : Rapid Development Framework (http://cakephp.org)
 * Copyright 2005-2010, Cake Software Foundation, Inc. (http://cakefoundation.org)
 *
 * Licensed under The MIT License
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright 2005-2010, Cake Software Foundation, Inc. (http://cakefoundation.org)
 * @link          http://cakephp.org CakePHP(tm) Project
 * @package       cake
 * @subpackage    cake.cake.console.libs.templates.skel.views.layouts
 * @since         CakePHP(tm) v 0.10.0.1076
 * @license       MIT License (http://www.opensource.org/licenses/mit-license.php)
 */
?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <?php echo $this->Html->charset(); ?>
    <title>
      <?php __('CakePHP: Evaluating Spine.Js:'); ?>
      <?php echo $title_for_layout; ?>
    </title>
    <?php
    echo $this->Html->meta('icon');

    //echo $this->Html->css('cake.generic');

    echo $this->Html->css('spine/application');

    echo $this->Html->script('lib/json2');

    echo $this->Html->script('lib/underscore.debug');

    echo $this->Html->script('lib/jquery-1.6.1');
    echo $this->Html->script('lib/jquery.tmpl');
    echo $this->Html->script('lib/jquery.ui.core');
    echo $this->Html->script('lib/jquery.ui.widget');
    echo $this->Html->script('lib/jquery.ui.mouse');
    echo $this->Html->script('lib/jquery.ui.sortable');

    echo $this->Html->script('spine/lib/spine');
    echo $this->Html->script('spine/lib/spine.local');
    echo $this->Html->script('spine/lib/spine.ajax');
    echo $this->Html->script('spine/app/todos/models/task');
    echo $this->Html->script('spine/app/todos/application');

    echo $html->scriptStart();
    ?>
    var base_url = '<?php echo $html->url('/'); ?>';
    <?php
    echo $html->scriptEnd();

    echo $scripts_for_layout;
    ?>
  </head>
  <body>
    <?php echo $content_for_layout; ?>
    <?php echo $this->element('sql_dump'); ?>
  </body>
</html>