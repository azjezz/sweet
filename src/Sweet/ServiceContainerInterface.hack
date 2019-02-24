/*
 * This file is part of the Sweet package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Sweet;

interface ServiceContainerInterface {
  public function get<T>(typename<T> $id): T;

  public function has<T>(typename<T> $id): bool;
}
